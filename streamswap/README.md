The concept of offering an **early subscriber pledge** (e.g., 50 ATOM / 200 USDC) that unlocks a **DCA (Dollar-Cost Averaging)** feature is a **unique and compelling feature** for StreamSwap. Here's how it could work as an **optimal use case**:

### **Overview of the Use Case:**
- **Early Pledge Requirement**: Participants who commit at least **50 ATOM / 200 USDC** before the stream starts will unlock the option to **DCA into the stream**.
- **DCA Option**: Once unlocked, these participants can continue to add funds gradually over time, as the sale progresses. They would receive the benefit of **purchasing tokens at different price points**, which helps mitigate risk from potential price fluctuations during the stream.

### **Unique Value Proposition:**
This approach is valuable both for the stream owner and for the participants. Here's why:

#### **For Stream Owners:**
1. **Increased Initial Commitment**:
   - By requiring an initial commitment (50 ATOM / 200 USDC), stream owners ensure that early participants are serious and committed to the sale. This builds confidence and increases the initial pool of funds.
   
2. **Longer Participation & Continued Engagement**:
   - Unlocking the DCA feature creates an incentive for early participants to stay engaged with the sale over time. This increases the **total funds pledged** throughout the sale, which can help maintain liquidity and prevent abrupt token dumps.
   
3. **Predictable Stream Dynamics**:
   - Knowing that participants have committed to the early pledge and will likely DCA in the future allows the stream owner to better predict the flow of tokens and funds. This helps in managing the price and distribution dynamically as more pledges are added.

4. **Attractive Offer for Participants**:
   - Offering the DCA option can make the sale more appealing, especially for those who prefer not to commit a large sum all at once but want to participate in the sale over time. This attracts a broader range of participants, potentially increasing the overall number of pledgers and diversifying the pool.

#### **For Participants (Early Subscribers):**
1. **Risk Mitigation with DCA**:
   - Participants who pledge early and unlock the DCA feature are able to **average out their entry price** by buying more tokens at different intervals. This reduces the risk of entering the sale at a high point if the token price fluctuates.
   
2. **Flexibility in Investment**:
   - The ability to DCA over time allows participants to stay in the sale while having more control over how and when they invest. It can be particularly attractive in a volatile market.
   
3. **Potential Better Allocation**:
   - Early subscribers who commit a higher pledge might receive a **larger share** of the token distribution, and DCAing into the stream over time could help secure even more favorable allocations.
   
4. **Incentivized Participation**:
   - Unlocking this feature for early subscribers creates an incentive for participants to **act quickly**. It’s a win-win situation: the participant secures access to future token purchases at different prices, while the stream owner secures initial pledges to kick off the sale.

#### **How It Could Be Implemented:**

1. **Create Early Subscriber Pool**:
   - Implement a system where users who pledge the minimum (50 ATOM / 200 USDC) are placed in an **early subscriber pool**. These participants are then granted access to an additional "DCA Option" button once the stream begins.
   
2. **Unlock DCA Mechanism**:
   - After the initial pledge, allow these participants to add funds incrementally (minutes, hours, etc.), with each additional pledge being averaged into the overall token price. 
   
3. **Track Progress and Distribute Tokens**:
   - Ensure that the smart contract tracks the total pledged amount, adjusting the **distribution balance** based on each user’s share of the stream, including the effects of DCA. 
   
4. **Bonus or Incentives for Early Subscribers**:
   - To further encourage early pledges, consider offering an **incentive** (e.g., additional tokens or a lower price point for early birds) that boosts the value of the early subscriber’s position.

### **Potential Benefits of the Strategy:**

1. **Increased Liquidity for the Stream**: 
   - Early pledges provide an early influx of capital, and DCA ensures that additional funds keep flowing in steadily, creating liquidity for token distribution.

2. **More Balanced Token Distribution**: 
   - Since participants can buy over time, the buying pressure is more evenly spread out, preventing huge spikes in token demand at any single point. This can help reduce market volatility during the sale.

3. **Attracts a Larger Pool of Participants**: 
   - This feature can attract smaller investors who may have been hesitant to pledge large sums upfront. The ability to DCA makes the sale accessible to a broader audience.

4. **Enhanced User Engagement**:
   - Offering DCA as a feature will keep early participants engaged with the sale over time. The ability to adjust their position continuously will encourage them to monitor and stay involved in the sale, potentially leading to a more loyal and invested user base.

### **Considerations for Implementation:**
1. **Smart Contract Logic**:
   - The smart contract will need to support the DCA mechanism by allowing additional pledges over time and correctly adjusting the amount of tokens purchased, ensuring that participants receive their proper share.

2. **Price and Token Distribution**:
   - The sale price may need to adjust dynamically to reflect the total pledged amount and remaining time in the sale, ensuring fairness for all participants.

3. **User Interface (UI)**:
   - Make sure the UI clearly communicates the DCA feature and how it works, especially for early participants. Offering real-time updates on the participant’s pledge and purchased tokens can enhance the user experience.

### **Conclusion:**
Introducing the **early subscription pledge** and unlocking a **DCA feature** is a highly **unique and valuable strategy** for StreamSwap. It benefits both the **stream owner** by increasing liquidity and engagement, and the **participants** by offering flexibility and risk mitigation. By implementing this mechanism, you can create a more attractive and sustainable sale event that appeals to a broader range of investors, while also ensuring that the stream is well-capitalized and efficiently managed.



- `Sender`: IBC packet senders cannot be explicitly trusted, as they can be deceitful. Chains cannot risk the sender being confused with a particular local user or module address. To prevent this, the `sender` is replaced with an account that represents the sender prefixed by the channel and a Wasm module prefix. This is done by setting the sender to `Bech32(Hash("ibc-wasm-hook-intermediary" || channelID || sender))`, where the `channelId` is the channel id on the local chain.

we can do via ibc hooks + Cosmos as unwrapping. We can not trust the sender but that does not matter, we will deposit it into contract and we set the operator that can control it when the funds are there in the contract. Also we trust the chain in the middle as that is the chain the token is from.

Adjust the script to use it as a memo

