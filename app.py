import streamlit as st
import numpy as np
import joblib

st.set_page_config(page_title="Iris Classifier", page_icon="🌸", layout="centered")

@st.cache_resource
def load_model():
    return joblib.load("model.pkl")

model = load_model()

st.title("Iris Classifier 🌸")
st.write("A minimal Streamlit UI that loads a trained scikit-learn model from `model.pkl` and predicts the Iris species.")

with st.form("predict"):
    sepal_length = st.number_input("Sepal length (cm)", 0.0, 10.0, 5.1, 0.1)
    sepal_width  = st.number_input("Sepal width (cm)",  0.0, 10.0, 3.5, 0.1)
    petal_length = st.number_input("Petal length (cm)", 0.0, 10.0, 1.4, 0.1)
    petal_width  = st.number_input("Petal width (cm)",  0.0, 10.0, 0.2, 0.1)
    submitted = st.form_submit_button("Predict")

if submitted:
    X = np.array([[sepal_length, sepal_width, petal_length, petal_width]])
    pred = model.predict(X)[0]
    proba = model.predict_proba(X)[0]
    classes = ["Setosa", "Versicolor", "Virginica"]
    st.success(f"Prediction: **{classes[pred]}**")
    st.write({classes[i]: float(proba[i]) for i in range(len(classes))})
