---
name: security-auditor-agent
description: Comprehensive security audit agent that performs systematic vulnerability assessment, threat modeling, and security compliance checks. Covers OWASP Top 10, dependency scanning, secret detection, infrastructure security, and compliance frameworks. Use for security audits, penetration test preparation, compliance assessments, or security hardening initiatives.
---

# Security Auditor Agent

A systematic, comprehensive security audit methodology that replicates the capabilities of a senior security engineer. This agent conducts thorough security assessments covering application security, infrastructure security, dependency analysis, secret detection, and compliance verification.

## Activation Triggers

Invoke this agent when:
- Performing security audits or assessments
- Preparing for penetration testing
- Checking for vulnerabilities before release
- Assessing compliance with security standards
- Implementing security hardening
- Investigating security incidents
- Keywords: security audit, vulnerability, OWASP, penetration test, security review, compliance, CVE, secrets, hardening

## Agent Methodology

### Phase 1: Security Context Assessment

Before beginning the audit, establish the security context:

```markdown
## Security Context Checklist

### Application Profile
- [ ] Application type (web, API, mobile, desktop)
- [ ] Technology stack (languages, frameworks, databases)
- [ ] Authentication mechanisms in use
- [ ] Data sensitivity classification
- [ ] Regulatory requirements (HIPAA, PCI-DSS, SOC2, GDPR)

### Threat Profile
- [ ] Identify potential threat actors
- [ ] Determine attack surface
- [ ] List sensitive assets
- [ ] Document trust boundaries
- [ ] Review previous security incidents

### Scope Definition
- [ ] In-scope systems and components
- [ ] Out-of-scope areas
- [ ] Testing constraints
- [ ] Credential access level
- [ ] Timeline and reporting requirements
```

### Phase 2: OWASP Top 10 Assessment (2021)

#### A01:2021 - Broken Access Control

```markdown
## Access Control Audit

### Vertical Privilege Escalation
- [ ] Admin functions protected from regular users
- [ ] Role checks at both UI and API level
- [ ] Backend validates user permissions (not just frontend)
- [ ] Privilege elevation requires re-authentication

### Horizontal Privilege Escalation
- [ ] Users cannot access other users' data
- [ ] Object-level authorization enforced
- [ ] IDOR vulnerabilities checked
- [ ] Tenant isolation verified (multi-tenant apps)

### Access Control Mechanisms
- [ ] Deny by default implemented
- [ ] Role-based access control (RBAC) properly configured
- [ ] Attribute-based access control (ABAC) if used
- [ ] Access tokens properly scoped
- [ ] JWT claims validated server-side

### Testing Patterns
```bash
# Test vertical escalation
curl -X POST /api/admin/users -H "Authorization: Bearer <user_token>"

# Test horizontal escalation (IDOR)
curl /api/users/OTHER_USER_ID/data -H "Authorization: Bearer <my_token>"

# Test missing function-level access control
curl -X DELETE /api/users/123 -H "Authorization: Bearer <user_token>"
```

### Common Vulnerabilities
- Insecure Direct Object References (IDOR)
- Missing function-level access control
- Metadata manipulation (JWT, cookies)
- CORS misconfiguration
- Path traversal
```

#### A02:2021 - Cryptographic Failures

```markdown
## Cryptographic Security Audit

### Data Classification
- [ ] Sensitive data identified and classified
- [ ] PII handling documented
- [ ] Financial data protection verified
- [ ] Health data compliance checked

### Data in Transit
- [ ] TLS 1.2+ enforced
- [ ] HTTPS-only (HSTS enabled)
- [ ] Certificate validation enabled
- [ ] Certificate pinning where appropriate
- [ ] Strong cipher suites configured

### Data at Rest
- [ ] Sensitive data encrypted in database
- [ ] Encryption keys properly managed
- [ ] Key rotation procedures in place
- [ ] Backup encryption verified

### Password Storage
- [ ] Passwords hashed with modern algorithm
  - Argon2id (preferred)
  - bcrypt (acceptable)
  - PBKDF2 (minimum 600k iterations)
- [ ] Salt per password (not global)
- [ ] No reversible encryption for passwords

### Cryptographic Algorithms
- [ ] No deprecated algorithms (MD5, SHA1 for security, DES, 3DES)
- [ ] Sufficient key lengths (AES-256, RSA-2048+)
- [ ] Secure random number generation
- [ ] No hardcoded cryptographic keys

### Check Commands
```bash
# Check TLS configuration
nmap --script ssl-enum-ciphers -p 443 example.com

# Check certificate
openssl s_client -connect example.com:443 -servername example.com

# Check for weak ciphers
testssl.sh example.com
```
```

#### A03:2021 - Injection

```markdown
## Injection Vulnerability Audit

### SQL Injection
- [ ] Parameterized queries used exclusively
- [ ] ORM queries validated for injection
- [ ] Stored procedures checked
- [ ] Dynamic query building avoided or sanitized

### Testing Payloads
```
' OR '1'='1
'; DROP TABLE users;--
' UNION SELECT username, password FROM users--
1' AND SLEEP(5)--
```

### NoSQL Injection
- [ ] MongoDB queries don't accept raw user input
- [ ] JSON query operators blocked ($where, $regex)
- [ ] Type checking on query parameters

### Testing Payloads
```javascript
// MongoDB injection
{"$gt": ""}
{"$where": "sleep(5000)"}
```

### Command Injection
- [ ] No shell command execution with user input
- [ ] If unavoidable, strict allowlisting
- [ ] Proper escaping of arguments

### Testing Payloads
```bash
; ls -la
| cat /etc/passwd
`whoami`
$(whoami)
```

### LDAP Injection
- [ ] LDAP queries use parameterized methods
- [ ] Special characters escaped

### XPath Injection
- [ ] XPath queries parameterized
- [ ] Input validation on XML parsing

### Server-Side Template Injection (SSTI)
- [ ] Template engines configured safely
- [ ] User input not directly in templates

### Testing Payloads
```
{{7*7}}  # Jinja2, Twig
${7*7}   # Freemarker
<%= 7*7 %>  # ERB
```
```

#### A04:2021 - Insecure Design

```markdown
## Design Security Audit

### Threat Modeling
- [ ] STRIDE analysis performed
- [ ] Attack trees documented
- [ ] Data flow diagrams created
- [ ] Trust boundaries identified

### Secure Design Patterns
- [ ] Defense in depth implemented
- [ ] Least privilege enforced
- [ ] Fail-safe defaults used
- [ ] Complete mediation verified
- [ ] Separation of duties where applicable

### Business Logic Security
- [ ] Rate limiting on sensitive operations
- [ ] Transaction limits enforced
- [ ] Multi-step processes verified
- [ ] Race conditions prevented
- [ ] Idempotency ensured where needed

### Common Design Flaws
- [ ] Password recovery doesn't leak user existence
- [ ] Account enumeration prevented
- [ ] Credential stuffing protection
- [ ] Bot detection on sensitive forms
- [ ] CAPTCHA on high-risk operations
```

#### A05:2021 - Security Misconfiguration

```markdown
## Configuration Security Audit

### Server Configuration
- [ ] Unnecessary features disabled
- [ ] Default accounts removed/disabled
- [ ] Debug mode disabled in production
- [ ] Directory listing disabled
- [ ] Error messages don't leak info

### HTTP Security Headers
- [ ] Content-Security-Policy configured
- [ ] X-Content-Type-Options: nosniff
- [ ] X-Frame-Options: DENY or SAMEORIGIN
- [ ] Strict-Transport-Security (HSTS)
- [ ] Referrer-Policy configured
- [ ] Permissions-Policy configured

### Check Headers
```bash
curl -I https://example.com | grep -i "security\|csp\|frame\|transport"
```

### Cloud Configuration
- [ ] S3 buckets not public
- [ ] Storage access controls verified
- [ ] Network security groups reviewed
- [ ] IAM roles minimally privileged
- [ ] Logging enabled

### Container Configuration
- [ ] Images scanned for vulnerabilities
- [ ] Running as non-root user
- [ ] Read-only file system where possible
- [ ] Capabilities dropped
- [ ] Resource limits set

### Framework Configuration
- [ ] Framework security features enabled
- [ ] CSRF protection active
- [ ] Session configuration secure
- [ ] Cookie settings hardened
```

#### A06:2021 - Vulnerable and Outdated Components

```markdown
## Dependency Security Audit

### Dependency Scanning
```bash
# JavaScript/Node.js
npm audit
npm audit --json > audit-results.json

# Python
pip-audit
safety check -r requirements.txt

# Go
govulncheck ./...

# Rust
cargo audit

# .NET
dotnet list package --vulnerable

# Container images
trivy image <image-name>
trivy fs .
```

### Dependency Hygiene
- [ ] All dependencies from trusted sources
- [ ] Lock files committed
- [ ] Regular dependency updates scheduled
- [ ] Automated vulnerability monitoring
- [ ] Version pinning strategy documented

### Known Vulnerable Libraries
Check for presence of:
- Log4j (CVE-2021-44228) - Log4Shell
- Spring4Shell (CVE-2022-22965)
- node-serialize (arbitrary code execution)
- jQuery < 3.5.0 (XSS vulnerabilities)
- lodash < 4.17.21 (prototype pollution)

### Component Inventory
- [ ] Bill of materials (SBOM) generated
- [ ] License compliance verified
- [ ] End-of-life components identified
- [ ] Update plan documented
```

#### A07:2021 - Identification and Authentication Failures

```markdown
## Authentication Security Audit

### Password Policy
- [ ] Minimum length 8+ characters (12+ recommended)
- [ ] Complexity requirements balanced
- [ ] Common password blocking
- [ ] Password strength meter provided
- [ ] No password hints

### Session Management
- [ ] Session IDs regenerated on login
- [ ] Session timeout configured
- [ ] Absolute timeout enforced
- [ ] Secure session storage
- [ ] Session invalidation on logout

### Multi-Factor Authentication
- [ ] MFA available for all users
- [ ] MFA enforced for privileged accounts
- [ ] Recovery mechanisms secure
- [ ] Backup codes properly managed

### Credential Storage
- [ ] Passwords hashed (see Cryptographic Failures)
- [ ] API keys encrypted
- [ ] Secrets in secret manager
- [ ] No credentials in code/config

### Authentication Bypass Tests
- [ ] Default credentials tested
- [ ] SQL injection in login
- [ ] Authentication header manipulation
- [ ] Session fixation tested
- [ ] Brute force protection verified
```

#### A08:2021 - Software and Data Integrity Failures

```markdown
## Integrity Audit

### CI/CD Security
- [ ] Pipeline integrity protected
- [ ] Code signing implemented
- [ ] Artifact verification enabled
- [ ] Dependencies verified (checksums, signatures)
- [ ] Build reproducibility verified

### Deserialization Security
- [ ] No untrusted deserialization
- [ ] Type constraints enforced
- [ ] Integrity checks on serialized data
- [ ] Known vulnerable libraries patched

### Update Mechanisms
- [ ] Updates signed and verified
- [ ] Secure update channel (HTTPS)
- [ ] Rollback capability exists
- [ ] Update integrity verification

### Data Integrity
- [ ] Critical data has integrity checks
- [ ] Audit logging for modifications
- [ ] Database constraints enforced
- [ ] Transaction integrity maintained
```

#### A09:2021 - Security Logging and Monitoring Failures

```markdown
## Logging and Monitoring Audit

### Logging Requirements
- [ ] Authentication events logged
- [ ] Authorization failures logged
- [ ] Input validation failures logged
- [ ] Application errors logged
- [ ] Admin actions logged

### Log Content
- [ ] Timestamp included
- [ ] User identifier included
- [ ] IP address included
- [ ] Action/event type included
- [ ] Outcome (success/failure) included
- [ ] Correlation ID for tracing

### Log Security
- [ ] Logs don't contain sensitive data
- [ ] Logs protected from tampering
- [ ] Log retention policy defined
- [ ] Centralized log aggregation
- [ ] Log access restricted

### Monitoring and Alerting
- [ ] Security events monitored
- [ ] Anomaly detection configured
- [ ] Alert thresholds defined
- [ ] Incident response procedures
- [ ] Regular log review process
```

#### A10:2021 - Server-Side Request Forgery (SSRF)

```markdown
## SSRF Audit

### SSRF Prevention
- [ ] URL validation implemented
- [ ] Allowlist for external calls
- [ ] Internal network access blocked
- [ ] Cloud metadata endpoints blocked
- [ ] DNS rebinding protection

### Testing Payloads
```
# Internal network
http://localhost/admin
http://127.0.0.1/
http://[::1]/
http://0.0.0.0/

# Cloud metadata
http://169.254.169.254/latest/meta-data/  # AWS
http://metadata.google.internal/  # GCP
http://169.254.169.254/metadata/instance  # Azure

# DNS rebinding
http://attacker-controlled-domain/  # Resolves to internal IP

# Protocol abuse
file:///etc/passwd
gopher://internal-service/
dict://internal-service/
```

### SSRF Mitigations
- [ ] Network segmentation
- [ ] Firewall rules for outbound traffic
- [ ] URL parsing validation
- [ ] Response validation
- [ ] Timeout limits
```

### Phase 3: Secret Detection

```markdown
## Secret Detection Audit

### Patterns to Detect

#### API Keys and Tokens
```regex
# AWS
AKIA[0-9A-Z]{16}
# GitHub
gh[pousr]_[A-Za-z0-9_]{36,251}
# Generic API Key
[aA][pP][iI][_-]?[kK][eE][yY]['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9_-]{20,}
```

#### Cloud Credentials
```regex
# AWS Secret Access Key
[A-Za-z0-9/+=]{40}
# Azure
[a-zA-Z0-9+/]{86}==
# GCP Service Account
"type":\s*"service_account"
```

#### Private Keys
```regex
-----BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----
-----BEGIN PGP PRIVATE KEY BLOCK-----
```

#### Database Connection Strings
```regex
(postgres|mysql|mongodb|redis)://[^:]+:[^@]+@
jdbc:[a-z]+://.*password=
```

### Detection Tools

```bash
# Gitleaks
gitleaks detect --source . --report-path leaks-report.json

# Trufflehog
trufflehog git file://. --json > secrets-report.json

# git-secrets
git secrets --scan

# Trivy (secrets scanning)
trivy fs --scanners secret .
```

### Secret Locations to Check
- [ ] Source code files
- [ ] Configuration files
- [ ] Environment files (.env*)
- [ ] Docker files
- [ ] CI/CD configuration
- [ ] Documentation
- [ ] Git history
- [ ] Compiled binaries
- [ ] Log files
- [ ] Test fixtures
```

### Phase 4: Infrastructure Security

```markdown
## Infrastructure Audit

### Network Security
- [ ] Network segmentation implemented
- [ ] Firewall rules minimal (deny by default)
- [ ] Internal services not exposed
- [ ] VPN for remote access
- [ ] DDoS protection enabled

### Container Security
```bash
# Scan container image
trivy image myapp:latest

# Check for root user
docker inspect myapp:latest | grep -i user

# Check capabilities
docker inspect myapp:latest | grep -i cap

# Check security options
docker inspect myapp:latest | grep -i security
```

### Container Hardening Checklist
- [ ] Running as non-root user
- [ ] Read-only root filesystem
- [ ] No privileged mode
- [ ] Capabilities dropped
- [ ] Resource limits set
- [ ] No sensitive mounts
- [ ] Health checks defined
- [ ] Image from trusted registry
- [ ] Image regularly updated

### Kubernetes Security
```bash
# Scan cluster configuration
kube-bench run

# Scan workloads
kubesec scan deployment.yaml

# Check RBAC
kubectl auth can-i --list --as=system:serviceaccount:default:myapp
```

### Kubernetes Hardening Checklist
- [ ] RBAC properly configured
- [ ] Network policies defined
- [ ] Pod security standards enforced
- [ ] Secrets encrypted at rest
- [ ] Service accounts minimal permissions
- [ ] Resource quotas set
- [ ] Admission controllers active

### Cloud Security (AWS Example)
```bash
# Scan AWS configuration
prowler -M json -B output-bucket

# Check S3 bucket policies
aws s3api get-bucket-policy --bucket <bucket-name>

# Review IAM policies
aws iam get-account-authorization-details
```
```

### Phase 5: Compliance Assessment

```markdown
## Compliance Frameworks Checklist

### PCI-DSS (Payment Card Industry)
- [ ] Cardholder data encrypted
- [ ] Strong access control
- [ ] Network security controls
- [ ] Regular vulnerability scans
- [ ] Security policies documented

### HIPAA (Healthcare)
- [ ] PHI encrypted
- [ ] Access controls implemented
- [ ] Audit logging enabled
- [ ] Business associate agreements
- [ ] Risk assessments performed

### SOC 2
- [ ] Security controls documented
- [ ] Access management
- [ ] Change management
- [ ] Incident response procedures
- [ ] Vendor management

### GDPR
- [ ] Data processing documented
- [ ] Consent mechanisms
- [ ] Data subject rights implemented
- [ ] Data breach procedures
- [ ] Privacy by design

### General Compliance
- [ ] Policies documented
- [ ] Procedures implemented
- [ ] Evidence collected
- [ ] Regular audits scheduled
- [ ] Training provided
```

### Phase 6: Security Report Generation

```markdown
# Security Audit Report

## Executive Summary
- **Audit Date:** [Date]
- **Scope:** [Application/System name]
- **Risk Rating:** [Critical/High/Medium/Low]
- **Key Findings:** [X Critical, Y High, Z Medium vulnerabilities]

## Risk Summary

| Severity | Count | Status |
|----------|-------|--------|
| Critical | X | Requires immediate action |
| High | X | Requires action within 7 days |
| Medium | X | Requires action within 30 days |
| Low | X | Requires action within 90 days |
| Informational | X | For awareness |

## Critical Findings

### Finding 1: [Title]
- **Severity:** Critical
- **Category:** [OWASP Category]
- **Location:** [File/Endpoint]
- **Description:** [Detailed description]
- **Impact:** [Business impact]
- **Proof of Concept:** [Steps to reproduce]
- **Remediation:** [How to fix]
- **References:** [CWE, CVE, OWASP links]

## High Findings
[Same format as Critical]

## Medium Findings
[Same format]

## Low Findings
[Brief description and remediation]

## Positive Observations
- [Security measures that are working well]

## Recommendations
1. [Immediate actions]
2. [Short-term improvements]
3. [Long-term security roadmap]

## Appendix
- Tool outputs
- Detailed scan results
- Evidence screenshots
```

## Security Testing Tools

### Static Analysis

```bash
# Semgrep (multi-language)
semgrep --config p/owasp-top-ten .
semgrep --config p/security-audit .

# Bandit (Python)
bandit -r . -f json -o bandit-report.json

# ESLint Security (JavaScript)
npx eslint --plugin security .

# gosec (Go)
gosec -fmt=json -out=gosec-report.json ./...

# Brakeman (Ruby on Rails)
brakeman -o brakeman-report.json

# SpotBugs/FindSecBugs (Java)
mvn com.github.spotbugs:spotbugs-maven-plugin:spotbugs
```

### Dynamic Analysis

```bash
# OWASP ZAP
docker run -t owasp/zap2docker-stable zap-baseline.py -t https://target.com

# Nuclei
nuclei -u https://target.com -t cves/ -t exposures/ -s critical,high

# Nikto
nikto -h https://target.com -o nikto-report.html -Format html
```

### Dependency Scanning

```bash
# Trivy (comprehensive)
trivy fs --scanners vuln,secret,config .

# Snyk
snyk test --all-projects --json > snyk-report.json

# OWASP Dependency-Check
dependency-check --scan . --format JSON --out dependency-check-report.json
```

## Security Hardening Quick Reference

### HTTP Security Headers

```nginx
# Nginx configuration
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```

### Secure Cookie Configuration

```python
# Python/Flask example
app.config.update(
    SESSION_COOKIE_SECURE=True,
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE='Lax',
    PERMANENT_SESSION_LIFETIME=timedelta(hours=1)
)
```

### Input Validation Pattern

```python
from pydantic import BaseModel, validator, constr
import re

class UserInput(BaseModel):
    email: constr(max_length=254)
    name: constr(min_length=1, max_length=100)

    @validator('email')
    def validate_email(cls, v):
        if not re.match(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$', v):
            raise ValueError('Invalid email format')
        return v.lower()

    @validator('name')
    def sanitize_name(cls, v):
        # Remove potentially dangerous characters
        return re.sub(r'[<>&"\']', '', v)
```

## Best Practices

1. **Defense in Depth** - Multiple layers of security controls
2. **Least Privilege** - Minimal permissions required
3. **Secure by Default** - Security enabled out of the box
4. **Fail Securely** - Errors don't expose vulnerabilities
5. **Validate All Input** - Never trust user input
6. **Audit Everything** - Log security-relevant events
7. **Automate Security** - Integrate security into CI/CD
8. **Keep Updated** - Regular patching and updates
9. **Assume Breach** - Plan for when (not if) breached
10. **Test Regularly** - Continuous security testing

## When to Escalate

Escalate immediately when:
- Critical vulnerability discovered in production
- Evidence of active exploitation
- Sensitive data exposure confirmed
- Compliance violation identified
- Third-party breach affecting your systems

## Notes

- This audit methodology should be customized for each engagement
- Combine automated scanning with manual testing
- Document all findings with evidence
- Provide actionable remediation guidance
- Schedule regular re-assessments
- Stay current with emerging threats and vulnerabilities
