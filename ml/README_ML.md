# 🐾 PawFinder NGO Classification ML Pipeline

This directory contains the machine learning classification service for the **PawFinder** NGO referral system.

## 🎯 Purpose
When a user submits an animal help request (e.g. *"Injured bird trapped in kite string near home"*), the ML classifier predicts the required organization category:
- `wildlife_rescue` (Wildlife SOS, Raptor Rescue)
- `animal_ngo` (Animal Welfare, Stray Rescue)
- `vet_hospital` (Veterinary Clinic / Hospital)
- `shelter` (Animal Shelter / Adoption Center)
- `govt_vet_hospital` (Government Veterinary Facility)

The predicted category is then used to query verified NGOs stored in Supabase with PostGIS distance calculation. **The ML model only classifies the required organization type; it never invents non-existent NGOs.**

---

## 🚀 Setup & Execution Instructions

### 1. Install Dependencies
```bash
pip install pandas numpy scikit-learn joblib fastapi uvicorn
```

### 2. Train and Export the Model
Run the training script to parse `dataset.csv`, extract TF-IDF features, train a Scikit-Learn Random Forest Classifier, and export `ngo_classifier.joblib`:
```bash
python train_ngo_classifier.py
```

### 3. Launch the REST API Service
Start the FastAPI service on port 8000:
```bash
uvicorn api_service:app --host 0.0.0.0 --port 8000 --reload
```

---

## 🔄 Production Integration & Fallback
- In Flutter, `NgoMlService` connects to `http://localhost:8000/classify-ngo` (or your cloud endpoint).
- If the ML server is unreachable, the Flutter app gracefully switches to an on-device rule-based fallback classifier (`NgoMlService.fallbackClassify()`) ensuring 100% uptime.
