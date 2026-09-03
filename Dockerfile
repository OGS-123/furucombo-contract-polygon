# Dockerfile - Builds ghcr.io/YOURNAME/furucombo-contract from dinngo/furucombo-contract-polygon
# Ready Deployed FlashLoan / FlashSwap Executors - Anyone can use - No redeploy needed - Just call proxy/pool
# Uses proxies WITHOUT redeploying - No permission - 0% fee - Permissionless

FROM node:20-alpine AS builder

WORKDIR /app

# Install git + clone furucombo polygon contracts - Has Proxy, Registry, Handler - MIT - Free
RUN apk add --no-cache git python3 make g++

# Clone dinngo/furucombo-contract-polygon - Has Proxy gateway - Ready deployed at 0x17e6dE1a56b5f0Aa32E2178e9b3E2C4dB6B3927B - No redeploy
RUN git clone https://github.com/dinngo/furucombo-contract-polygon.git./furucombo

WORKDIR /app/furucombo

# Install deps - Furucombo uses npm
RUN npm install

# Copy your custom wrapper that uses ready deployed proxies WITHOUT redeploying - No deploy - Just call proxy/pool
WORKDIR /app
COPY./contracts./contracts
COPY./README.md./README.md

# Final image - With all ready deployed executors info - No redeploy needed - Just call
FROM node:20-alpine

WORKDIR /app

# Labels for GHCR - Free - Open source - Public - Anyone can fork
LABEL org.opencontainers.image.title="furucombo-contract - Ready Deployed FlashLoan Executor - No Redeploy Needed"
LABEL org.opencontainers.image.description="Furucombo Polygon Proxy 0x17e6dE1a56b5f0Aa32E2178e9b3E2C4dB6B3927B + 1inch V6 0x111111125421ca6dc452d289314280a0f8842a65 0% FREE + 0x 0xDef1C0ded9bec7F1a1670819833240f027b25EfF Polygon + Balancer 0xBA12222222228d8Ba445958a75a0704d566BF2C8 0% FREE + Aave V3 0x794a61358D6845594F94dc1DB02A252b5b665AC - All used WITHOUT redeploying - Just call proxy/pool"
LABEL org.opencontainers.image.source="https://github.com/dinngo/furucombo-contract-polygon"
LABEL org.opencontainers.image.licenses="MIT"

# Copy furucombo contracts + your wrapper
COPY --from=builder /app/furucombo./furucombo
COPY --from=builder /app/contracts./contracts

# Install ethers for WP plugin that uses wrappers WITHOUT redeploying - No external - WP plugin alone
RUN npm init -y && npm install ethers@6.10.0 @1inch/fusion-sdk @0x/contract-wrappers

# Create ready deployed executors list - No redeploy - Just call proxy/pool - Anyone can use
RUN echo '{ \
  "ready_executors": { \
    "Furucombo_Old_Polygon": "0x17e6dE1a56b5f0Aa32E2178e9b3E2C4dB6B3927B", \
    "Furucombo_New_Polygon": "0x1721a66b1E8F5bCf3D78de8541Dd8bB6e1F4cEA8", \
    "1inch_V6_Router": "0x111111125421ca6dc452d289314280a0f8842a65", \
    "0x_Exchange_Proxy_Polygon": "0xDef1C0ded9bec7F1a1670819833240f027b25EfF", \
    "Balancer_Vault_0pct": "0xBA12222222228d8Ba445958a75a0704d566BF2C8", \
    "Aave_V3_Pool_Polygon": "0x794a61358D6845594F94dc1DB02A252b5b665AC", \
    "Uniswap_V3_Router": "0xE592427A0AEce92De3Edee1F18E0157C05861564", \
    "QuickSwap_Router": "0xa5E0829CaCEd8fFDD4De3c436d0b0D115a88FE76" \
  }, \
  "permission_needed": false, \
  "need_deploy": false, \
  "usage": "Use WITHOUT redeploying - Just call proxy/pool - Permissionless - 0% fee - Takes surplus for 1inch V6", \
  "wp_plugin": "WP plugin alone + public RPC + wrapper used WITHOUT redeploying - No Bunny Edge - No external" \
}' > /app/ready-executors.json

# Expose for WP plugin - No private key in image - Safe - Uses MetaMask
EXPOSE 3000

# Default command - Show ready executors - No redeploy needed
CMD ["sh", "-c", "cat /app/ready-executors.json && echo '--- Ready Deployed FlashLoan Executors - No redeploy - Just call proxy/pool - ghcr.io/YOURNAME/furucombo-contract - Free - Anyone can use - No permission' && ls -la /app/furucombo"]
