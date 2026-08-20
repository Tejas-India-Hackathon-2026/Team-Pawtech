import pandas as pd
import numpy as np
import joblib
import os
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score

def train_ngo_recommendation_model(data_path="dataset.csv", output_model_path="ngo_classifier.joblib"):
    """
    PawFinder NGO Recommendation ML Pipeline
    Trains a text & categorical classification model using Pandas and Scikit-Learn
    to classify animal distress reports into required NGO categories:
      - animal_ngo (Animal Welfare / Rescue)
      - wildlife_rescue (Wildlife SOS / Raptor Rescue)
      - vet_hospital (Emergency Veterinary Hospital)
      - shelter (Animal Shelter / Adoption Center)
      - govt_vet_hospital (Government Vet Clinic)
    """
    print("🐾 Loading PawFinder NGO training dataset...")
    if not os.path.exists(data_path):
        raise FileNotFoundError(f"Dataset not found at {data_path}")

    df = pd.read_csv(data_path)
    print(f"Total dataset size: {len(df)} samples")
    print(df.head())

    # Preprocessing: Combine animal_type, problem, and description into a single feature string
    df['combined_features'] = df['animal_type'].fillna('') + ' ' + \
                              df['problem'].fillna('') + ' ' + \
                              df['description'].fillna('') + ' ' + \
                              df['location'].fillna('')

    X = df['combined_features']
    y = df['ngo_type']

    # Train / Test split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

    print("\n⚡ Building TF-IDF + Random Forest Classification Pipeline...")
    model_pipeline = Pipeline([
        ('tfidf', TfidfVectorizer(ngram_range=(1, 2), max_features=1000, stop_words='english')),
        ('classifier', RandomForestClassifier(n_estimators=100, random_state=42))
    ])

    # Fit Model
    model_pipeline.fit(X_train, y_train)

    # Evaluate
    y_pred = model_pipeline.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    print(f"\n✅ Model Evaluation Accuracy: {acc * 100:.2f}%")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred))

    # Export Model
    joblib.dump(model_pipeline, output_model_path)
    print(f"🎉 Model exported successfully to '{output_model_path}'")

def predict_ngo_category(model_path, animal_type, problem, description, location=""):
    """Inference function for a single distress query"""
    if not os.path.exists(model_path):
        # Clean Fallback Classification Logic if model file not exported yet
        print("⚠️ Model file not found. Executing fallback classification logic.")
        text = f"{animal_type} {problem} {description}".lower()
        if any(w in text for w in ['bird', 'snake', 'monkey', 'eagle', 'wild', 'owl', 'reptile', 'turtle']):
            return 'wildlife_rescue'
        elif any(w in text for w in ['vaccination', 'hospital', 'surgery', 'clinic', 'bite', 'doctor']):
            return 'vet_hospital'
        elif any(w in text for w in ['adoption', 'shelter', 'abandoned', 'puppies', 'stray kitten']):
            return 'shelter'
        else:
            return 'animal_ngo'

    pipeline = joblib.load(model_path)
    combined = f"{animal_type} {problem} {description} {location}"
    prediction = pipeline.predict([combined])[0]
    return prediction

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_file = os.path.join(script_dir, "dataset.csv")
    model_file = os.path.join(script_dir, "ngo_classifier.joblib")
    
    train_ngo_recommendation_model(data_file, model_file)

    # Test sample inference
    test_res = predict_ngo_category(model_file, "Bird", "Injury", "Injured parrot caught in kite string")
    print(f"\nSample Prediction for 'Injured parrot in kite string': -> {test_res}")
