import os
import json
import uuid
from vector_embedding import generate_embedding


DB_FILE = "db.json"

def load_db():
    if os.path.exists(DB_FILE):
        with open(DB_FILE, "r") as f:
            return json.load(f)
    return []

def save_db(data):
    with open(DB_FILE, "w") as f:
        json.dump(data, f, indent=4)

def add_note(summary_text):
    db = load_db()

    # Generate ID and embedding
    note_id = f"summary_{str(uuid.uuid4())[:4]}"
    embedding = generate_embedding(summary_text)

    # Generate tags
    # tags = extract_tags(summary_text)

    # Create base note
    note = {
        "id": note_id,
        "embedding": embedding,
        "text": summary_text,
        "tags": [],
        "backlinks": []
    }

    # Compute backlinks with cosine similarity ≥ 0.8
   

    db.append(note)
    save_db(db)
    print(f"Note '{note_id}' added.")

# Example usage
if __name__ == "__main__":
    sample_summary1 = """
Meeting Summary: Arbitrage Model for Index Basket Trading
Overview:
We discussed implementing an arbitrage trading model based on pricing inefficiencies between index baskets and their underlying assets.
Key Concepts:
Arbitrage Definition: Exploiting price discrepancies between an index (e.g., S&P-like basket) and its component stocks.
Pricing Inefficiencies: The sum of individual stock prices may not match the index price due to supply-demand dynamics, creating arbitrage opportunities.
Strategy:
If index price > sum of components → Short index, Long components.
If index price < sum of components → Long index, Short components.
Positions are liquidated when prices converge.
Structure:
Three assets and two baskets:
Basket A – contains all 3 assets.
Basket B – contains 2 of the 3.
Types of Arbitrage:
Arbitrage between Basket A and all 3 products.
Arbitrage between Basket B and the 2 products.
Arbitrage using Basket A = Basket B + Product 3.
Current Progress:
Entry logic for trades has been implemented.
Remaining Tasks:
Implement position liquidation logic when prices converge.
Ensure no position limits are exceeded when using overlapping products across multiple baskets.
"""
    add_note(sample_summary1)
    sample_summary2 = """Meeting Summary: Sentiment Analysis for Customer Support Tickets  
Overview:  
The discussion centered on using NLP techniques to classify and prioritize customer support tickets based on sentiment.  
Key Concepts:  
Sentiment Detection: Classifying tickets into positive, neutral, or negative categories.  
Urgency Mapping: Using sentiment scores to route critical issues to support staff faster.  
Strategy:  
Train a BERT-based classifier on historical tickets.  
Integrate the model with ticketing system via REST API.  
Flag negative or frustrated customer messages for high-priority resolution.  
Structure:  
Two-tier system:  
Tier 1 – sentiment classification (model inference).  
Tier 2 – urgency routing and alerting.  
Model Retraining Plan:  
Weekly retraining with newly labeled data.  
Periodic A/B testing to evaluate accuracy improvement.  
Current Progress:  
Prototype model achieves 84% accuracy.  
Remaining Tasks:  
Deploy inference service to production.  
Implement feedback loop from agents to improve model over time.  
"""
    add_note(sample_summary2)
    sample_summary3 = """Meeting Summary: Feature Prioritization for Q2 Product Roadmap  
Overview:  
We aligned on key product features to prioritize for Q2 based on user feedback and market trends.  
Key Concepts:  
Customer Impact: Features that directly address top pain points.  
Revenue Potential: Features that support monetization or user growth.  
Strategy:  
Score each feature based on effort vs. impact.  
Rank features and select top 5 for development.  
Reserve 20% bandwidth for technical debt and refactoring.  
Structure:  
Three product categories:  
Onboarding – Improve new user experience.  
Engagement – Increase time spent in app.  
Conversion – Drive upgrades to premium.  
Scoring Model:  
Weighted score matrix based on product analytics and surveys.  
Current Progress:  
Feature list compiled and scored.  
Remaining Tasks:  
Finalize dev resourcing and timelines.  
Lock scope and notify stakeholders.  
"""
    add_note(sample_summary3)
    sample_summary4 = """Meeting Summary: Testing and Refinement of Index Basket Arbitrage Model  
Overview:  
This follow-up meeting focused on evaluating the performance of the arbitrage trading model in simulated market conditions and refining the logic for position liquidation.  

Key Concepts:  
Backtesting Framework: Ran simulations using historical index and component stock data to validate strategy assumptions.  
Convergence Logic: Defined thresholds for identifying when index and component prices have “converged” sufficiently to trigger liquidation.  
Risk Mitigation: Introduced position limits and fail-safes to prevent overexposure in volatile conditions.  

Strategy Updates:  
- Dynamic Thresholds: Adjust convergence criteria based on basket volatility.  
- Position Caps: Enforced maximum allocation per product to avoid portfolio imbalance.  
- Liquidity Check: Verify real-time liquidity before executing offsetting trades.  

Structure Enhancements:  
- Position Tracker Module: Tracks open positions across both baskets and assets.  
- Alert System: Generates warnings when nearing position limits or during illiquid market windows.  

Current Progress:  
- Backtesting complete with average PnL improvements of 6–9% over baseline.  
- Liquidation logic implemented with adjustable thresholds.  

Remaining Tasks:  
- Run stress tests with extreme market events (e.g., flash crashes).  
- Integrate real-time price feed to transition from simulation to live testing.  
- Begin phased deployment in paper trading environment before full automation.  
"""
    add_note(sample_summary4)
    sample_summary5 = """Meeting Summary: Operational Readiness and Paper Trading Review for Arbitrage Model  
Overview:  
This session reviewed the performance of the arbitrage strategy in the paper trading environment and finalized preparations for live market deployment.  

Key Concepts:  
Execution Latency: Measured time between signal generation and simulated order placement to assess real-world feasibility.  
Slippage Impact: Evaluated difference between expected and executed prices during volatile periods.  
System Health Monitoring: Defined observability metrics and alert thresholds to ensure model stability during runtime.  

Paper Trading Results:  
- 30-day simulation across two market cycles.  
- Average execution latency: 180ms  
- Slippage remained within acceptable bounds (<0.3%) in 92% of trades.  
- Realized PnL aligned with backtest projections, confirming strategy robustness.  

Deployment Plan:  
- Phase 1: Run model in shadow mode alongside manual trades for validation.  
- Phase 2: Enable automated trade execution with capped position sizing.  
- Fail-safe triggers implemented for order rejection, excessive drawdown, and latency spikes.  

Current Progress:  
- Paper trading environment stable and consistent with historical expectations.  
- Model deployed on staging server with live market data feed enabled.  

Remaining Tasks:  
- Final approval from compliance team for production use.  
- Conduct dry-run session during market hours to test alerting, logging, and trade audit trail.  
- Schedule full production deployment with monitoring active for first week.    
"""
    add_note(sample_summary5)
    