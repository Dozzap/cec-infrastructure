import os
import uuid
import logging
import json
import requests
import paho.mqtt.client as mqtt

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# MQTT configuration (update these as needed)
MQTT_BROKER = os.environ.get("MQTT_BROKER", "3.96.200.35")  # Cloud MQTT broker public IP
MQTT_PORT = int(os.environ.get("MQTT_PORT", "31883"))
MQTT_TOPIC = os.environ.get("MQTT_TOPIC", "pipeline/tts/out")

# TTS Service endpoint (this is the local endpoint of your text2speech container)
SERVICE_ENDPOINTS = {
    "text2speech": os.environ.get("TTS_SERVICE_ENDPOINT", "http://127.0.0.1:5001/process")
}

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        logging.info("🟢 Connected to MQTT Broker successfully.")
        # Start the workflow once connected
        message = "This is a damn mess..."
        run_workflow(client, message)
    else:
        logging.error(f"❌ Connection failed with code {rc}")

def on_publish(client, userdata, mid):
    logging.info(f"✅ Message published with ID: {mid}")
    # Optionally disconnect after publishing to end the workflow
    client.disconnect()

def run_workflow(client, message):
    try:
        logging.info("🚀 Starting Text-to-Speech process...")
        # Send POST request to the text-to-speech service with the message as JSON data
        tts_resp = requests.post(SERVICE_ENDPOINTS["text2speech"],
                                 json={"message": message},
                                 timeout=30)
        tts_resp.raise_for_status()
        
        tts_audio = tts_resp.content
        logging.info("🎧 TTS processing complete. Publishing audio to MQTT...")
        
        # Publish the audio result over MQTT
        client.publish(MQTT_TOPIC, payload=tts_audio, qos=0, retain=False)
    except requests.HTTPError as http_err:
        logging.error(f"HTTP error occurred: {http_err}")
    except Exception as e:
        logging.error(f"Unexpected error in workflow: {e}")

if __name__ == "__main__":
    client = mqtt.Client(protocol=mqtt.MQTTv311)
    client.on_connect = on_connect
    client.on_publish = on_publish

    logging.info("📡 Connecting to MQTT Broker...")
    try:
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
    except Exception as e:
        logging.error(f"Failed to connect to MQTT Broker: {e}")
        exit(1)

    client.loop_forever()
