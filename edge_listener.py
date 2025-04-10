import paho.mqtt.client as mqtt
import uuid

# Use the externally accessible IP of your Cloud MQTT broker.
# Ensure this matches what your Cloud MQTT Broker is exposing.
MQTT_BROKER = "207.61.171.152"
MQTT_PORT = 31883
# TOPIC = "pipeline/final/out"  # This topic should match the final output topic from your Cloud workflow

TOPIC = "pipeline/compression/out"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("🟢 Edge connected to cloud broker")
        client.subscribe(TOPIC)
    else:
        print(f"❌ Edge failed to connect, code {rc}")

def on_message(client, userdata, msg):
    print(f"🎧 Received final audio ({len(msg.payload)} bytes)")
    filename = f"edge_output_{uuid.uuid4().hex}.mp3"
    with open(filename, "wb") as f:
        f.write(msg.payload)
    print(f"💾 Saved as {filename}")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

print("📡 Listening for final audio from cloud...")
client.connect(MQTT_BROKER, MQTT_PORT, 60)
client.loop_forever()
