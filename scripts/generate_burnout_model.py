import os
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split

print("Generating synthetic data for Burnout Prediction...")
# Features: [SleepHours, StressLevel, ClinicalDutiesPerWeek, MealsSkipped]
# Labels: 0 (Low), 1 (Medium), 2 (High)
np.random.seed(42)
num_samples = 1000

# Generate random features
sleep_hours = np.random.uniform(2, 10, num_samples)
stress_level = np.random.randint(1, 6, num_samples)
duties = np.random.randint(0, 6, num_samples)
meals_skipped = np.random.randint(0, 4, num_samples)

# Simple logic to define burnout risk based on features
# Higher stress, fewer sleep hours, more duties, more skipped meals = higher risk
scores = (6 - sleep_hours)*2 + stress_level*3 + duties*2 + meals_skipped*2

labels = []
for s in scores:
    if s < 15:
        labels.append(0) # Low
    elif s < 25:
        labels.append(1) # Medium
    else:
        labels.append(2) # High

X = np.column_stack((sleep_hours, stress_level, duties, meals_skipped)).astype(np.float32)
y = np.array(labels)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

print("Building sequential model...")
model = tf.keras.Sequential([
    tf.keras.layers.Dense(16, activation='relu', input_shape=(4,)),
    tf.keras.layers.Dense(16, activation='relu'),
    tf.keras.layers.Dense(3, activation='softmax') # 3 classes
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

print("Training model...")
model.fit(X_train, y_train, epochs=50, verbose=0)
loss, acc = model.evaluate(X_test, y_test, verbose=0)
print(f"Model trained! Test Accuracy: {acc*100:.2f}%")

# Save as TensorFlow Lite model
print("Converting to TFLite format...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

file_path = "assets/models/burnout_model.tflite"
with open(file_path, "wb") as f:
    f.write(tflite_model)

print(f"Success! Model saved to {file_path}")
