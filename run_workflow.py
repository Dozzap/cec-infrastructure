import paho.mqtt.client as mqtt
import requests
import json
from pathlib import Path

# MQTT configuration for Wavelength (ensure it resolves correctly)
MQTT_BROKER = "mosquitto-service.wavelength"  # Replace with actual Wavelength MQTT Broker IP if necessary
MQTT_TOPIC = "pipeline/tts/out"  # Topic for TTS output

# Endpoint for the Text-to-Speech service running on your laptop
SERVICE_ENDPOINTS = {
    "text2speech": "http://127.0.0.1:5001/process",  # TTS service URL
}

# Callback functions for MQTT client
def on_connect(client, userdata, flags, rc):
    print(f"Connected to MQTT Broker with result code {rc}")
    # Continue with the workflow after connecting
    message = "This is a damn mess..."  # Example message to send to TTS
    run_workflow(message)

def on_publish(client, userdata, mid):
    print(f"Message Published, ID: {mid}")

def run_workflow(message):
    try:
        print("Starting Text-to-Speech...")

        # TTS Processing (sending request to your local TTS service)
        tts_resp = requests.post(SERVICE_ENDPOINTS["text2speech"], 
                                 json={"message": message}, timeout=30)
        tts_resp.raise_for_status()

        # Send the generated audio to the MQTT broker
        client = mqtt.Client()
        client.on_connect = on_connect
        client.on_publish = on_publish

        # Connect to the Wavelength MQTT broker
        client.connect(MQTT_BROKER, 1883, 60)

        # Publish TTS output to MQTT broker (Wavelength)
        tts_audio = tts_resp.content  # The audio content from TTS service
        client.publish(MQTT_TOPIC, payload=tts_audio, qos=0, retain=False)

        print("✅ TTS audio published to Wavelength MQTT Broker!")

        # Block until the message is sent and keep the client loop running
        client.loop_forever()

    except Exception as e:
        print(f"❌ Workflow failed: {str(e)}")
        # Debugging help:
        print("\nDebug Info:")
        print(f"Text-to-Speech status: {tts_resp.status_code if 'tts_resp' in locals() else 'N/A'}")

if __name__ == "__main__":
    # MQTT Client will trigger the workflow after connecting
    client = mqtt.Client()
    client.on_connect = on_connect
    client.connect(MQTT_BROKER, 1883, 60)  # Make sure Wavelength broker is reachable
    client.loop_start()
