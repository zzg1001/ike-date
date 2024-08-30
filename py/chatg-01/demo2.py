import os
from openai import AzureOpenAI

client = AzureOpenAI(
  azure_endpoint = "https://ai-zuogongzhangai6573653805773011.openai.azure.com", 
  api_key="4ca4e46700614918858ea9bc2068e273",  
  api_version="2024-03-01-preview"
)

response = client.chat.completions.create(
  model="gpt-4o", # Model = should match the deployment name you chose for your 0125-Preview model deployment
  response_format={ "type": "json_object" },
  messages=[
    {"role": "system", "content": "You are a helpful assistant designed to output JSON."},
    {"role": "user", "content": "Who won the world series in 2020?"}
  ]
)
print(response.choices[0].message.content)