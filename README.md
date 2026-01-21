# Relief - Emergency Grant Distribution Protocol

A transparent aid distribution system for emergency response funding built on the Stacks blockchain using Clarity smart contracts.

## Overview

Relief is a decentralized grant distribution protocol designed to provide transparent and accountable emergency response funding. The contract ensures that all aid distributions are recorded on-chain, creating an immutable audit trail while maintaining security through role-based access control.

## Features

- **Transparent Fund Management**: All deposits and distributions are publicly verifiable on-chain
- **Role-Based Access Control**: Owner and authorized distributors manage grant approvals
- **Immutable Grant Records**: Every grant includes recipient, amount, purpose, and timestamp
- **Disbursement Protection**: Prevents double-spending and unauthorized distributions
- **Public Accountability**: Anyone can verify grant details and fund balances

## Contract Architecture

### Data Structures

**Emergency Fund**
- Stores total available STX for grant distribution
- Updated on deposits and disbursements

**Grants Map**
- `grant-id`: Unique identifier
- `recipient`: Beneficiary principal address
- `amount`: STX amount allocated
- `purpose`: Description of aid (max 256 characters)
- `disbursed`: Boolean flag to prevent double disbursement
- `timestamp`: Block height when grant was created
- `approved-by`: Principal who approved the grant

**Authorized Distributors**
- Map of principals authorized to create and disburse grants

## Functions

### Public Functions

#### Fund Management

**`deposit-funds (amount uint)`**
- Deposits STX into the emergency fund
- Anyone can contribute
- Returns: Amount deposited

**`emergency-withdraw (amount uint)`**
- Owner-only function to withdraw funds
- Emergency fund recovery mechanism
- Returns: Amount withdrawn

#### Authorization Management

**`add-distributor (distributor principal)`**
- Adds authorized grant distributor
- Owner-only function
- Returns: Success boolean

**`remove-distributor (distributor principal)`**
- Removes distributor authorization
- Owner-only function
- Returns: Success boolean

#### Grant Operations

**`create-grant (recipient principal) (amount uint) (purpose string-ascii)`**
- Creates a new grant record
- Requires: Owner or authorized distributor
- Validates sufficient funds available
- Returns: Grant ID

**`disburse-grant (grant-id uint)`**
- Transfers approved grant to recipient
- Requires: Owner or authorized distributor
- Prevents double disbursement
- Returns: Success boolean

### Read-Only Functions

**`get-fund-balance ()`**
- Returns current emergency fund balance

**`get-grant (grant-id uint)`**
- Returns complete grant details
- Public transparency function

**`get-total-grants ()`**
- Returns total number of grants created

**`is-authorized (distributor principal)`**
- Checks if a principal is an authorized distributor

## Usage Guide

### Deployment

1. Deploy the contract to Stacks blockchain
2. The deployer automatically becomes the contract owner and first authorized distributor

### Setup

```clarity
;; Add authorized distributors
(contract-call? .relief add-distributor 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)

;; Deposit emergency funds
(contract-call? .relief deposit-funds u1000000) ;; 1 STX = 1,000,000 microSTX
```

### Creating and Disbursing Grants

```clarity
;; Create a grant
(contract-call? .relief create-grant 
    'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 
    u500000 
    "Medical supplies for flood victims")
;; Returns: (ok u1) - Grant ID 1

;; Disburse the grant
(contract-call? .relief disburse-grant u1)
;; Returns: (ok true)
```

### Querying Information

```clarity
;; Check fund balance
(contract-call? .relief get-fund-balance)

;; View grant details
(contract-call? .relief get-grant u1)

;; Get total grants issued
(contract-call? .relief get-total-grants)
```

## Error Codes

- `u100` - Owner-only operation
- `u101` - Grant not found
- `u102` - Already exists
- `u103` - Insufficient funds
- `u104` - Unauthorized access
- `u105` - Grant already disbursed
- `u106` - Invalid amount (zero or negative)

## Security Considerations

### Access Control
- Only the contract owner can add/remove distributors
- Only owner and authorized distributors can create and disburse grants
- Emergency withdrawal restricted to owner only

### Fund Safety
- All funds are held in the contract until disbursed
- Disbursement validation prevents double-spending
- Amount validation ensures positive values only

### Transparency
- All grant information is publicly readable
- Immutable on-chain records create audit trail
- Block height timestamps provide temporal verification

## Use Cases

- **Natural Disaster Relief**: Rapid fund distribution to affected communities
- **Humanitarian Aid**: Transparent allocation of emergency assistance
- **Community Support**: Decentralized mutual aid networks
- **NGO Operations**: Accountable grant management for relief organizations
- **Government Programs**: Transparent emergency response funding

## Best Practices

1. **Multiple Distributors**: Authorize multiple trusted distributors for redundancy
2. **Clear Purpose Descriptions**: Use detailed grant purposes for transparency
3. **Regular Audits**: Monitor grants using read-only functions
4. **Fund Management**: Maintain adequate emergency fund balance
5. **Access Review**: Periodically review authorized distributors

## Development and Testing

### Requirements
- Clarinet CLI for local development
- Stacks blockchain testnet/mainnet access

### Testing
```bash
clarinet test
clarinet check
```

### Deployment
```bash
clarinet deploy --testnet
# or
clarinet deploy --mainnet
```

## Contributing

Contributions are welcome! Areas for enhancement:
- Multi-signature approval workflows
- Time-locked disbursements
- Category-based fund allocation
- Reporting and analytics features
- Integration with oracle systems for verification

## License

This smart contract is provided as-is for emergency relief purposes. Review and audit before production use.

## Support

For questions or issues, please review the contract code and test thoroughly before deployment to mainnet.

---

**Disclaimer**: This smart contract handles financial transactions. Always conduct thorough testing and security audits before deploying to production environments.