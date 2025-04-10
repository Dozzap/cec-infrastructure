import os
import uuid
import logging
import json
import requests
import paho.mqtt.client as mqtt

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# MQTT configuration – ensure that the external/public IP of your Cloud MQTT Broker is used
MQTT_BROKER = os.environ.get("MQTT_BROKER", "207.61.171.22").strip()
MQTT_PORT = int(os.environ.get("MQTT_PORT", "31883"))
MQTT_TOPIC = os.environ.get("MQTT_TOPIC", "pipeline/tts/out").strip()

# TTS Service endpoint (local endpoint from the text2speech container)
SERVICE_ENDPOINTS = {
    "text2speech": os.environ.get("TTS_SERVICE_ENDPOINT", "http://127.0.0.1:5001/process").strip()
}

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        logging.info("🟢 Connected to MQTT Broker successfully.")
        # Start the workflow once connected
        message = "please ufcking work omfg i will end myself"
        run_workflow(client, message)
    else:
        logging.error(f"❌ Connection failed with code {rc}")

def on_publish(client, userdata, mid):
    logging.info(f"✅ Message published with ID: {mid}")
    # Optionally disconnect after publishing if that's intended for your workflow
    client.disconnect()

def run_workflow(client, message):
    try:
        logging.info("🚀 Starting Text-to-Speech process...")
        # Send a POST request to the text-to-speech service with JSON payload
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
    client.enable_logger()  # This logs MQTT activities to Python’s logging system

    client.on_connect = on_connect
    client.on_publish = on_publish
    logging.info(" Connecting to MQTT Broker...")
    logging.info(f"Using MQTT Broker: '{MQTT_BROKER}', port: {MQTT_PORT}")
    try:
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
    except Exception as e:
        logging.error(f"Failed to connect to MQTT Broker: {e}")
        exit(1)

    client.loop_forever()
