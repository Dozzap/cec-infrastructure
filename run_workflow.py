import paho.mqtt.client as mqtt
import requests
import json

# MQTT configuration
MQTT_BROKER = "207.61.169.156"  # Wavelength MQTT broker
MQTT_PORT = 32157
MQTT_TOPIC = "pipeline/tts/out"

# Local TTS service endpoint
SERVICE_ENDPOINTS = {
    "text2speech": "http://127.0.0.1:5001/process",
}

def on_connect(client, userdata, flags, rc):
    print(f"✅ Connected to MQTT Broker with result code {rc}")

    # Start the workflow once connected
    message = "This is a damn mess..."
    run_workflow(client, message)

def on_publish(client, userdata, mid):
    print(f"📤 Message published with ID: {mid}")
    client.disconnect()  # Optional: disconnect after publishing

def run_workflow(client, message):
    try:
        print("🎤 Starting Text-to-Speech...")

        tts_resp = requests.post(SERVICE_ENDPOINTS["text2speech"],
                                 json={"message": message}, timeout=30)
        tts_resp.raise_for_status()

        tts_audio = tts_resp.content
        print("✅ TTS processing complete. Publishing...")

        # Publish the audio result
        client.publish(MQTT_TOPIC, payload=tts_audio, qos=0, retain=False)

    except Exception as e:
        print(f"❌ Workflow failed: {e}")
        print(f"Debug: TTS response status = {tts_resp.status_code if 'tts_resp' in locals() else 'N/A'}")

if __name__ == "__main__":
    # ✅ You were missing this line
    client = mqtt.Client(protocol=mqtt.MQTTv311)

    client.on_connect = on_connect
    client.on_publish = on_publish

    print("🚀 Connecting to MQTT broker...")
    client.connect(MQTT_BROKER, MQTT_PORT, 60)
    client.loop_forever()
