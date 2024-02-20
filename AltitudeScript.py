import pickle
import sklearn
import pandas as pd


# Load the model
with open('/Users/srinivas/AltitudeApp/knn_model.pkl', 'rb') as file:
    pipeline_classifier = pickle.load(file)

def get_prediction(new_data):
    # Assuming new_data is a DataFrame with the required structure
    processed_input = pipeline_classifier.named_steps['preprocessor'].transform(new_data)
    predicted_prob = pipeline_classifier.named_steps['grid_search'].best_estimator_.predict_proba(processed_input)
    ams_risk_probability = predicted_prob[0][1] * 100
    scaled_lls_score = round(ams_risk_probability / 100 * 12)
    return {'ams_risk_probability': ams_risk_probability, 'scaled_lls_score': scaled_lls_score}
    
# Create a sample DataFrame
sample_data = {
    'age': [49],
    'gender': ['M'],
    'permanent_altitude': [1],
    'bp_systolic': [1350],
    'bp_diastolic': [90],
    'spo2': [98],
    'pulse': [103],
    'hypertension': [1],
    'diabetes': [1],
    'ascent_day': [1],
    'smoking': [1],
    'sym_headache': [1],
    'sym_gi': [0],
    'sym_fatigue': [0],
    'sym_dizziness': [1]
}

sample_input_df = pd.DataFrame(sample_data)

# Test the get_prediction function
result = get_prediction(sample_input_df)
print(result)