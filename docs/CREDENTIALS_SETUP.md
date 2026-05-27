# API Credentials Setup Guide

Complete guide for setting up all required API credentials.

---

## 🔐 Jira API Credentials

### Step 1: Create Jira API Token

1. **Login to Atlassian Account**
   - Go to: https://id.atlassian.com/manage-profile/security/api-tokens

2. **Create New Token**
   - Click **"Create API token"**
   - Label: `n8n-automation` (or any descriptive name)
   - Click **"Create"**

3. **Copy Token**
   - ⚠️ **Important**: Copy immediately - you won't see it again!
   - Save securely (password manager recommended)

### Step 2: Find Your Jira Instance URL

Your Jira URL format: `https://[your-company].atlassian.net`

**To find it:**
- Check your browser when logged into Jira
- Example: `https://acmecorp.atlassian.net`

### Step 3: Add to n8n

1. In n8n: **Settings** → **Credentials** → **Add Credential**
2. Search: `Jira Software Cloud`
3. Fill in:
   ```
   Credential Name: Jira Account
   Jira URL: https://yourcompany.atlassian.net
   Email: your-email@company.com
   API Token: [paste token here]
   ```
4. Click **"Save"**

### Testing Jira Connection

In n8n workflow, test the "Get My Assigned Tasks" node to verify connection.

---

## 🪣 Bitbucket API Credentials

### Step 1: Create App Password

1. **Go to Bitbucket Settings**
   - URL: https://bitbucket.org/account/settings/app-passwords/
   - Or: Profile → Settings → App passwords

2. **Create App Password**
   - Click **"Create app password"**
   - Label: `n8n-automation`
   - Permissions required:
     - ✅ **Repositories: Read**
     - ✅ **Repositories: Write**
     - ✅ **Pull requests: Read and write** (optional, for future features)

3. **Copy Password**
   - ⚠️ Save immediately - won't be shown again!

### Step 2: Get Repository Information

You need:
- **Workspace name**: The organization/user name in Bitbucket
- **Repository name**: Your specific repo

**Example URL:** `https://bitbucket.org/acmecorp/my-project`
- Workspace: `acmecorp`
- Repository: `my-project`

### Step 3: Add to n8n

1. In n8n: **Settings** → **Credentials** → **Add Credential**
2. Search: `HTTP Basic Auth`
3. Fill in:
   ```
   Credential Name: Bitbucket Credentials
   Username: your-bitbucket-username
   Password: [paste app password here]
   ```
4. Click **"Save"**

### Step 4: Configure Environment Variables

Edit `.env` file:
```bash
BITBUCKET_WORKSPACE=your-workspace-name
BITBUCKET_REPO=your-repository-name
BITBUCKET_DEFAULT_BRANCH=main  # or master, develop, etc.
JIRA_URL=https://yourcompany.atlassian.net
```

Restart n8n:
```bash
docker-compose restart n8n
```

---

## 🤖 Rovo AI (Atlassian Intelligence)

### What is Rovo AI?

Atlassian's built-in AI that understands your Jira context, projects, and workflows.

### Requirements

- ✅ Jira Premium or Enterprise plan
- ✅ Atlassian Intelligence enabled by admin
- ✅ API access (uses your Jira credentials)

### Step 1: Check if Rovo is Available

1. **Login to Jira as Admin**
2. Go to: **Settings** (⚙️) → **Products** → **Atlassian Intelligence**
3. Verify it's **Enabled**

If not enabled:
- Contact your Jira administrator
- Or upgrade to Premium/Enterprise plan

### Step 2: Verify API Access

The workflow uses Rovo via Jira's REST API:
```
POST /rest/api/3/llm/analyze
```

**No separate credentials needed** - it uses your existing Jira API token!

### Alternative: If Rovo API is Not Available

The workflow has **automatic fallback logic**:
1. ✅ First tries Rovo AI
2. ✅ If fails, uses rule-based breakdown
3. ✅ Guarantees subtasks are always created

---

## 🔑 Optional: OpenAI/Anthropic (Alternative to Rovo)

If you prefer using OpenAI or Anthropic instead of Rovo:

### OpenAI Setup

1. **Get API Key**
   - Go to: https://platform.openai.com/api-keys
   - Create new secret key
   - Copy the key

2. **Add to n8n**
   - **Settings** → **Credentials** → **OpenAI API**
   - Paste API key
   - Save

3. **Modify Workflow**
   - Replace "Rovo AI" HTTP Request nodes
   - Use "OpenAI" node instead
   - Model: `gpt-4` or `gpt-4-turbo`

### Anthropic Claude Setup

1. **Get API Key**
   - Go to: https://console.anthropic.com/
   - Create API key
   - Copy the key

2. **Add to n8n**
   - **Settings** → **Credentials** → **Anthropic API**
   - Paste API key
   - Save

3. **Modify Workflow**
   - Replace "Rovo AI" nodes
   - Use "Anthropic Chat Model" node
   - Model: `claude-3-5-sonnet-20241022`

---

## 🔒 Security Best Practices

### 1. API Token Storage

✅ **DO:**
- Store tokens in n8n (encrypted in database)
- Use environment variables for configuration
- Use password manager for backup

❌ **DON'T:**
- Hardcode tokens in workflows
- Share tokens in public repositories
- Store in plain text files

### 2. Token Permissions

**Principle of Least Privilege:**
- Only grant necessary permissions
- Jira: API token (not OAuth for simplicity, but OAuth is more secure)
- Bitbucket: Only Repository Write access

### 3. Rotate Credentials Regularly

**Recommended:**
- Change API tokens every 90 days
- Update in n8n credentials
- Test workflows after rotation

### 4. Monitor Usage

**Jira:**
- Check audit logs: Settings → Audit log
- Monitor API usage

**Bitbucket:**
- Review app password usage in settings

---

## 🧪 Testing Credentials

### Test Jira Connection

```bash
# Using curl (replace with your credentials)
curl -u your-email@company.com:YOUR_API_TOKEN \
  https://yourcompany.atlassian.net/rest/api/3/myself
```

Expected: Your Jira user details

### Test Bitbucket Connection

```bash
# Using curl
curl -u your-username:YOUR_APP_PASSWORD \
  https://api.bitbucket.org/2.0/repositories/WORKSPACE/REPO
```

Expected: Repository information

### Test Rovo AI

```bash
# Using curl
curl -X POST \
  -u your-email@company.com:YOUR_API_TOKEN \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Test prompt", "context": "test"}' \
  https://yourcompany.atlassian.net/rest/api/3/llm/analyze
```

Expected: AI response or error message

---

## ❓ Troubleshooting

### "Authentication failed" Error

**Jira:**
- ✅ Check email address is exact match
- ✅ Verify API token is copied correctly (no spaces)
- ✅ Ensure Jira URL has `https://` and `.atlassian.net`

**Bitbucket:**
- ✅ Check username (not email)
- ✅ Verify app password permissions
- ✅ Ensure workspace/repo names are correct

### "Rovo AI not found" Error

- ✅ Verify Atlassian Intelligence is enabled
- ✅ Check Jira plan (Premium/Enterprise)
- ✅ Workflow will use fallback - no action needed

### "Rate limit exceeded" Error

**Solutions:**
- Wait a few minutes
- Reduce workflow frequency
- Contact Atlassian support for higher limits

---

## 📝 Credential Checklist

Before running workflow, verify:

- [ ] Jira API token created and saved in n8n
- [ ] Jira URL correct in credentials
- [ ] Bitbucket app password created and saved
- [ ] Bitbucket workspace/repo in `.env` file
- [ ] Environment variables loaded (`docker-compose restart`)
- [ ] Rovo AI enabled (or fallback understood)
- [ ] Test connection successful

---

## 🆘 Need Help?

**Atlassian Support:**
- Jira API Docs: https://developer.atlassian.com/cloud/jira/platform/rest/v3/
- Bitbucket API Docs: https://developer.atlassian.com/cloud/bitbucket/rest/

**n8n Support:**
- Credentials Guide: https://docs.n8n.io/credentials/
- Community: https://community.n8n.io/

---

**All credentials configured? → Go to [SETUP_GUIDE.md](SETUP_GUIDE.md) to continue!**
