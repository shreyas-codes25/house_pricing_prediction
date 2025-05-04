import os
from numpy import double
from flask import Flask, request, jsonify # type: ignore
from flask_cors import CORS # type: ignore
import pandas as pd
import xgboost as xgb # type: ignore
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
import joblib

MODEL_PATH = './xgb_model.pkl'
SCALER_PATH = './scaler.pkl'

df = pd.read_csv('./Housing.csv')
df = pd.get_dummies(df, drop_first=True)

X = df.drop('price', axis=1)
y = df['price']

if os.path.exists(MODEL_PATH) and os.path.exists(SCALER_PATH):
    # Load model and scaler if they exist
    model = joblib.load(MODEL_PATH)
    scaler = joblib.load(SCALER_PATH)
else:
    # Train the model if no saved model exists
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    model = xgb.XGBRegressor()
    model.fit(X_train_scaled, y_train)

    # Save the trained model and scaler for future use
    joblib.dump(model, MODEL_PATH)
    joblib.dump(scaler, SCALER_PATH)

    train_r2 = r2_score(y_train, model.predict(X_train_scaled))
    test_r2 = r2_score(y_test, model.predict(X_test_scaled))

    print(f"Training R² score: {train_r2:.4f}")
    print(f"Test R² score: {test_r2:.4f}")

app = Flask(__name__)
CORS(app, resources={r"/predict": {"origins": "*"}})

# Income classification function
def classify_income(price):
    if price < 1000000:
        return "Very Low"
    elif 1000000 <= price < 2000000:
        return "Low"
    elif 2000000 <= price < 3500000:
        return "Lower-Middle"
    elif 3500000 <= price < 5000000:
        return "Middle"
    elif 5000000 <= price < 7000000:
        return "Upper-Middle"
    elif 7000000 <= price < 10000000:
        return "High"
    else:
        return "Very High"


@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    input_data = pd.DataFrame([data])

    # Ensure all columns are present in input data
    missing_cols = set(X.columns) - set(input_data.columns)
    for col in missing_cols:
        input_data[col] = 0
    input_data = input_data[X.columns]

    # Scale the input data using the loaded scaler
    input_scaled = scaler.transform(input_data)
    prediction = model.predict(input_scaled)[0]

    # Income class based on predicted price
    income_class = classify_income(prediction)

    # Calculate confidence interval
    residuals = y - model.predict(scaler.transform(X))
    residual_std = residuals.std()
    confidence_interval = 1.96 * residual_std
    confidence_percentage = (1 - (confidence_interval / prediction)) * 100

    print(confidence_percentage)

    return jsonify({
        "predicted_price": double(prediction),
        "income_class": income_class,
        "confidence_interval": f"±{confidence_interval:.2f}",
        "confidence_percentage": f"{confidence_percentage:.2f}%"
    })

if __name__ == '__main__':
    #app.run(debug=True)
    # Run the Flask app
    # Set the host to '0.0.0.0' to allow external access
    app.run(host='0.0.0.0', port=5000, debug=True)

