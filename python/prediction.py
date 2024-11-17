from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import xgboost as xgb
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score

df = pd.read_csv('./Housing.csv')
df = pd.get_dummies(df, drop_first=True)

X = df.drop('price', axis=1)
y = df['price']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

model = xgb.XGBRegressor()
model.fit(X_train_scaled, y_train)

train_r2 = r2_score(y_train, model.predict(X_train_scaled))
test_r2 = r2_score(y_test, model.predict(X_test_scaled))

print(f"Training R² score: {train_r2:.4f}")
print(f"Test R² score: {test_r2:.4f}")

app = Flask(__name__)
CORS(app, resources={r"/predict": {"origins": "*"}})

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    input_data = pd.DataFrame([data])

    missing_cols = set(X.columns) - set(input_data.columns)
    for col in missing_cols:
        input_data[col] = 0
    input_data = input_data[X.columns]
    
    input_scaled = scaler.transform(input_data)
    prediction = model.predict(input_scaled)[0]
    
    residuals = y_train - model.predict(X_train_scaled)
    residual_std = residuals.std()
    confidence_interval = 1.96 * residual_std
    confidence_percentage = (1 - (confidence_interval / prediction)) * 100
    
    print(confidence_percentage)
    return jsonify({
        "predicted_price": float(prediction),
        "confidence_interval": f"±{confidence_interval:.2f}",
        "confidence_percentage": f"{confidence_percentage:.2f}%"
    })

if __name__ == '__main__':
    app.run(debug=True)
