import torch
from transformers import pipeline

# Specify the model ID
model_id = "meta-llama/Llama-3.2-1B-Instruct"

# Initialize the text generation pipeline
pipe = pipeline(
    "text-generation",
    model=model_id,
    torch_dtype=torch.bfloat16,
    device_map="auto",
)

# Define the conversation with a system prompt
messages = [
    {"role": "system", "content": "Summarize the transcript below using structured bullet points. Focus only on key ideas and technical details:"},
    {"role": "user", "content": "Yeah, so for the creating bot it's like an arbitrage model. So do you know what arbitrage is? No. Okay, so we have a index fund, right? Okay. Like S&B is like a bunch of different stocks in it. But its prices are not exactly determined by those individual stocks, but rather like has its every pricing fits on as well. Separate supply demand. So sometimes they can eat pricing efficiencies. Suppose there's an index fund of just like three products. You call it basket A and the two products are here. So sometimes when you add up the individual prices of those, it sometimes lower or higher than the actual price of the S&B or the basket price. That's when there's a pricing inefficiency. So you can export that. So if this is over-value, the meaning that the basket price is more than the combined price of the individual products, then you short this one because it's going to go down and you buy this one because it's going to go up and you sell it when they converge. Like you liquidate your positions when they converge. Here you buy it to go back to zero. You sell it back to zero. So that gives you short and profit. See, other way around then you short individual stocks and you buy the basket and you sell when they converge or like liquidate your positions. So that's the arbitrage model. Here are the two baskets, the three products. Okay? Two baskets. One basket has two of them. Third basket has all three of them. So that three types of arbitrage I'll do here. One is one arbitrage of the first basket. That basket in three products. There's the arbitrage with the second basket and the two products, but matching both of those. And lastly, it's the basket. Plus one basket and a product. Because remember when is three and when is two? Okay, yeah. So it'll be basket one equals basket two plus product three. That'll be three of it. So right now I've been in the code for entering the positions"},
]

# Generate a response
output = pipe(messages, max_new_tokens=256)
print(output[0]["generated_text"])
