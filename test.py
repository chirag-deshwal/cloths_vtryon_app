from gradio_client import Client
import json

client = Client('yisol/IDM-VTON')
api_info = client.view_api(return_format='dict')
with open('api_info.json', 'w', encoding='utf-8') as f:
    json.dump(api_info, f, indent=2)
