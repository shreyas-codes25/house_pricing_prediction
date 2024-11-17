from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from flask_cors import CORS


# Load your dataset
df = pd.read_csv(r'./Housing.csv')

# Preprocessing: Convert categorical variables into dummy/indicator variables
df = pd.get_dummies(df, drop_first=True)

# Define features (X) and target (y)
X = df.drop('price', axis=1)
y = df['price']

# Split the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Initialize the Linear Regression model
model = LinearRegression()
model.fit(X_train, y_train)  # Train the model

# Flask app setup
app = Flask(__name__)
CORS(app)

@app.route('/predict', methods=['POST'])
def predict():
    # Parse input JSON
    data = request.json
    
    # Convert input to DataFrame
    input_data = pd.DataFrame([data])

    # Ensure new data has the same columns as the training set
    missing_cols = set(X_train.columns) - set(input_data.columns)
    for col in missing_cols:
        input_data[col] = 0  # Fill missing columns with 0

    input_data = input_data[X_train.columns]  # Align column order

    # Make prediction
    prediction = model.predict(input_data)
    return jsonify({"predicted_price": prediction[0]})

if __name__ == '__main__':
    app.run(debug=True)
