from ollama import chat
from ollama import ChatResponse
from ollama import Client
import markdown
import re

def markdown_to_text(markdown_string):
    """Converts a markdown string to plaintext."""

    # Convert markdown to HTML
    html = markdown.markdown(markdown_string)

    # Remove HTML tags
    text = re.sub(r'<[^>]+>', '', html)

    return text

client = Client() 
prompt = f"""Make the following transcript into organized BULLETED meeting notes in markdown syntax. Make sure to add bullets. Add headers when necessary. 
Transcript: 
 Yeah so for the creating bot its like an arbitrage model So do you know what arbitrage 
 is No Okay so we have a index fund right Okay Like SB is like a bunch of different stocks 
 in it But its prices are not exactly determined by those individual stocks but rather like
   has its every pricing fits on as well Separate supply demand So sometimes they can eat pricing 
   efficiencies Suppose theres an index fund of just like three products You call it basket A 
   and the two products are here So sometimes when you add up the individual prices of those it 
   sometimes lower or higher than the actual price of the SB or the basket price Thats when theres 
   a pricing inefficiency So you can export that So if this is overvalue the meaning that the basket 
   price is more than the combined price of the individual products then you short this one because 
   its going to go down and you buy this one because its going to go up and you sell it when they 
   converge Like you liquidate your positions when they converge Here you buy it to go back to zero 
   You sell it back to zero So that gives you short and profit See other way around then you short 
   individual stocks and you buy the basket and you sell when they converge or like liquidate your 
   positions So thats the arbitrage model Here are the two baskets the three products Okay Two baskets 
   One basket has two of them Third basket has all three of them So that three types of arbitrage Ill do 
   here One is one arbitrage of the first basket That basket in three products Theres the arbitrage with 
   the second basket and the two products but matching both of those And lastly its the basket Plus one 
   basket and a product Because remember when is three and when is two Okay yeah So itll be basket one 
   equals basket two plus product three Thatll be three of it So right now Ive been in the code for 
   entering the positions but we still have to write the code for selling when it converges You also 
   have to check that we dont exceed the limits because three times when Im going over the same product
     essentially Okay What is all this over here is this This is a documentation This is something else
       but this is the actual code And ChatGPT write the like edit the thing to write the code 
       when we liquidate our positions """

response = client.generate(model='llama3.2:1b', prompt=prompt)
markdown_text = response['response']
final_text = markdown_to_text(markdown_text)
# for chunk in response:
#     print(chunk['response'], end='\n', flush=True)

print(markdown_text)

