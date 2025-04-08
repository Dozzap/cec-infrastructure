import paho.mqtt.client as mqtt
import uuid

MQTT_BROKER = "3.96.200.35"  # Cloud MQTT broker public IP
MQTT_PORT = 31883
TOPIC = "pipeline/final/out"  

def on_connect(client, userdata, flags, rc):
    print("🟢 Edge connected to cloud broker")
    client.subscribe(TOPIC)

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
