# Blockchain-Based Supply Chain Finance Trade Finance Systems

A comprehensive blockchain-based trade finance system built on the Stacks blockchain using Clarity smart contracts. This system provides secure, transparent, and efficient management of trade finance operations including letters of credit, invoice financing, payment coordination, and risk management.

## 🏗️ System Architecture

The system consists of five interconnected smart contracts:

### 1. Trade Finance Manager (`trade-finance-manager.clar`)
- **Purpose**: Validates and manages supply chain finance managers
- **Key Features**:
    - Manager verification and authorization
    - Performance tracking and risk scoring
    - License management with expiry dates
    - Manager reputation system

### 2. Letter of Credit (`letter-of-credit.clar`)
- **Purpose**: Manages letters of credit for international trade
- **Key Features**:
    - LC creation, issuance, and confirmation
    - Document presentation and verification
    - Automated payment processing
    - Multi-party workflow management

### 3. Invoice Financing (`invoice-financing.clar`)
- **Purpose**: Manages invoice financing for supply chain finance
- **Key Features**:
    - Invoice financing request creation
    - Discount rate calculations
    - Funding and repayment management
    - Default tracking and management

### 4. Payment Coordination (`payment-coordination.clar`)
- **Purpose**: Coordinates trade payments across different instruments
- **Key Features**:
    - Multi-currency payment support
    - Escrow balance management
    - Batch payment processing
    - Payment status tracking

### 5. Risk Management (`risk-management.clar`)
- **Purpose**: Manages trade finance risks and compliance
- **Key Features**:
    - Risk assessment and scoring
    - Compliance verification (KYC/AML)
    - Exposure limit management
    - Transaction risk evaluation

## 🚀 Getting Started

### Prerequisites

- Node.js (v16 or higher)
- Clarinet CLI
- Stacks Wallet

### Installation

1. Clone the repository:
   \`\`\`bash
   git clone <repository-url>
   cd blockchain-trade-finance
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Run tests:
   \`\`\`bash
   npm test
   \`\`\`

### Deployment

1. Configure your deployment settings in \`Clarinet.toml\`
2. Deploy to testnet:
   \`\`\`bash
   clarinet deploy --testnet
   \`\`\`

## 📋 Usage Examples

### Verifying a Trade Finance Manager

\`\`\`clarity
(contract-call? .trade-finance-manager verify-manager
'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
"John Doe"
"TFM12345"
u1000)
\`\`\`

### Creating a Letter of Credit

\`\`\`clarity
(contract-call? .letter-of-credit create-letter-of-credit
'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG  ;; beneficiary
'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC  ;; applicant
u100000                                        ;; amount
"USD"                                         ;; currency
u1500                                         ;; expiry
(list "Invoice" "Bill of Lading")             ;; documents
'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND)    ;; manager
\`\`\`

### Creating Invoice Financing

\`\`\`clarity
(contract-call? .invoice-financing create-invoice-financing
'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG  ;; buyer
'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC  ;; financier
u50000                                        ;; invoice amount
u500                                          ;; discount rate (5%)
u1200                                         ;; due date
'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND)    ;; manager
\`\`\`

## 🔒 Security Features

- **Access Control**: Role-based permissions for different operations
- **Compliance Checks**: KYC/AML verification requirements
- **Risk Management**: Automated risk assessment and exposure limits
- **Audit Trail**: Complete transaction history on blockchain
- **Multi-signature Support**: Enhanced security for high-value transactions

## 🧪 Testing

The project includes comprehensive test suites using Vitest:

- **Unit Tests**: Individual contract function testing
- **Integration Tests**: Cross-contract interaction testing
- **Edge Case Tests**: Error handling and boundary condition testing

Run tests with:
\`\`\`bash
npm test
\`\`\`

## 📊 Key Metrics and KPIs

- **Transaction Volume**: Total value processed through the system
- **Success Rate**: Percentage of successful transactions
- **Risk Score**: Automated risk assessment metrics
- **Compliance Rate**: KYC/AML verification success rate
- **Processing Time**: Average transaction processing duration

## 🔧 Configuration

### Environment Variables

- \`STACKS_NETWORK\`: Network configuration (testnet/mainnet)
- \`CONTRACT_DEPLOYER\`: Deployer address
- \`RISK_THRESHOLD\`: Global risk threshold settings

### Contract Parameters

- **Risk Levels**: LOW (1), MEDIUM (2), HIGH (3), CRITICAL (4)
- **Status Codes**: Various status codes for different contract states
- **Limits**: Exposure limits and transaction thresholds

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team
- Check the documentation wiki

## 🔮 Roadmap

- [ ] Multi-chain support
- [ ] Advanced analytics dashboard
- [ ] Mobile application
- [ ] API gateway integration
- [ ] Machine learning risk models
- [ ] Regulatory reporting automation

---

**Note**: This system uses \`stacks-block-height\` instead of \`block-height\` for Stacks blockchain compatibility.
\`\`\`

Finally, let's create the PR details:
