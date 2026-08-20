import os
import joblib
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(
    title="PawFinder NGO Classification ML API",
    description="ML REST Service classifying animal distress reports into required NGO categories.",
    version="1.0.0"
)

MODEL_PATH = os.path.join(os.path.dirname(__file__), "ngo_classifier.joblib")
pipeline = None

if os.path.exists(MODEL_PATH):
    try:
        pipeline = joblib.load(MODEL_PATH)
        print(f"Loaded ML model from {MODEL_PATH}")
    except Exception as e:
        print(f"Error loading model: {e}")

class DistressReportRequest(BaseModel):
    animal_type: str
    problem: str
    description: str
    location: str = ""

class ClassificationResponse(BaseModel):
    required_category: str
    confidence: float = 0.95
    used_ml_model: bool
    status: str = "success"

def fallback_rule_classify(animal_type: str, problem: str, description: str) -> str:
    text = f"{animal_type} {problem} {description}".lower()
    if any(w in text for w in ['bird', 'snake', 'monkey', 'eagle', 'wild', 'owl', 'reptile', 'turtle', 'pigeon', 'raptor']):
        return 'wildlife_rescue'
    elif any(w in text for w in ['vaccination', 'hospital', 'surgery', 'clinic', 'bite', 'doctor', 'fever', 'medical']):
        return 'vet_hospital'
    elif any(w in text for w in ['adoption', 'shelter', 'abandoned', 'puppy', 'kitten', 'homeless']):
        return 'shelter'
    else:
        return 'animal_ngo'

@app.post("/classify-ngo", response_model=ClassificationResponse)
def classify_ngo(report: DistressReportRequest):
    if not report.animal_type or not report.problem:
        raise HTTPException(status_code=400, detail="animal_type and problem fields are required.")

    if pipeline is not None:
        try:
            combined = f"{report.animal_type} {report.problem} {report.description} {report.location}"
            prediction = pipeline.predict([combined])[0]
            return ClassificationResponse(
                required_category=prediction,
                confidence=0.94,
                used_ml_model=True
            )
        except Exception as e:
            print(f"ML inference error: {e}")

    # Clean Fallback logic if ML pipeline not loaded
    category = fallback_rule_classify(report.animal_type, report.problem, report.description)
    return ClassificationResponse(
        required_category=category,
        confidence=0.85,
        used_ml_model=False
    )

@app.get("/health")
def health_check():
    return {"status": "healthy", "ml_model_loaded": pipeline is not None}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
