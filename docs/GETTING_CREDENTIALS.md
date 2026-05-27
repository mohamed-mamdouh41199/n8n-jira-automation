# Step-by-Step Credentials Setup Guide

Follow these steps to get your Jira and Bitbucket credentials ready for n8n.

---

## 📋 Prerequisites Checklist

Before starting, make sure you have:
- [ ] Jira Cloud account with access to your workspace
- [ ] Bitbucket Cloud account with repository access
- [ ] Admin or appropriate permissions in both platforms

---

## 🔐 STEP 1: Get Jira API Credentials

### 1.1 Login to Jira

1. Go to your Jira instance: `https://yourcompany.atlassian.net`
2. Login with your credentials
3. Verify you can see your projects and tasks

### 1.2 Find Your Jira URL

Your Jira URL format: `https://[your-company].atlassian.net`

**Example:**
- If you access Jira at `https://acmecorp.atlassian.net`
- Your JIRA_URL is: `https://acmecorp.atlassian.net`

**Save this for later!** ✍️

### 1.3 Create Jira API Token

1. **Go to API Token page:**
   ```
   https://id.atlassian.com/manage-profile/security/api-tokens
   ```

2. **Click "Create API token"**

3. **Give it a label:**
   - Label: `n8n-automation`
   - Click **Create**

4. **Copy the token IMMEDIATELY**
   - ⚠️ **IMPORTANT**: You won't see it again!
   - Click **Copy** button
   - Paste it somewhere safe (password manager or notes)

5. **Your API token looks like:**
   ```
   ATATT3xFfGF0b...random...characters...xyz123
   ```

**Save these details:** ✍️
```
Jira URL: https://yourcompany.atlassian.net
Jira Email: your-email@company.com
API Token: ATATT3xFfGF0b...
```

---

## 🪣 STEP 2: Get Bitbucket API Credentials

### 2.1 Login to Bitbucket

1. Go to: `https://bitbucket.org`
2. Login with your credentials
3. Navigate to your repository

### 2.2 Find Your Workspace and Repository Names

From your repository URL, identify the workspace and repo:

**Example URL:**
```
https://bitbucket.org/acmecorp/my-project
                      ↑          ↑
                   Workspace    Repo Name
```

**Save these:** ✍️
```
Workspace: acmecorp
Repository: my-project
```

### 2.3 Create App Password

1. **Go to Settings:**
   ```
   https://bitbucket.org/account/settings/app-passwords/
   ```
   Or: Click your avatar → **Personal settings** → **App passwords**

2. **Click "Create app password"**

3. **Configure permissions:**
   - **Label**: `n8n-automation`
   - **Permissions** (select these):
     - ✅ **Repositories: Read**
     - ✅ **Repositories: Write**
     - ✅ **Pull requests: Read** (optional, for future features)

4. **Click "Create"**

5. **Copy the password IMMEDIATELY**
   - ⚠️ **IMPORTANT**: You won't see it again!
   - It looks like: `ATBBxyz123abc...`
   - Save it securely

**Save these details:** ✍️
```
Bitbucket Username: your-username
Bitbucket App Password: ATBBxyz123abc...
Bitbucket Workspace: acmecorp
Bitbucket Repository: my-project
Default Branch: main (or master)
```

---

## ⚙️ STEP 3: Update .env File

Now update your `.env` file with the credentials you collected:

### 3.1 Open .env file

```bash
cd /Users/mohamedmamdouh/Desktop/Automation/n8n-jira-automation
nano .env
# or use your preferred editor: code .env, vim .env
```

### 3.2 Update these lines:

```bash
# Jira Configuration
JIRA_URL=https://yourcompany.atlassian.net
# ↑ Replace with YOUR Jira URL

# Bitbucket Configuration
BITBUCKET_WORKSPACE=your-workspace-name
# ↑ Replace with YOUR workspace

BITBUCKET_REPO=your-repository-name
# ↑ Replace with YOUR repository name

BITBUCKET_DEFAULT_BRANCH=main
# ↑ Change if using 'master' or other default branch
```

### 3.3 Generate Secure Password (Optional)

If you want a stronger database password:

```bash
# Generate random password
openssl rand -base64 20
```

Replace the `POSTGRES_PASSWORD` in .env:
```bash
POSTGRES_PASSWORD=YourGeneratedPasswordHere
```

### 3.4 Save the file

Press `Ctrl+O`, then `Enter`, then `Ctrl+X` (if using nano)

---

## ✅ STEP 4: Verify Your Configuration

### 4.1 Check .env file

```bash
cat .env
```

Make sure all values are filled (no placeholders left).

### 4.2 Your .env should look like:

```bash
N8N_PORT=5678
N8N_PROTOCOL=http
N8N_HOST=localhost
N8N_ENCRYPTION_KEY=jYgrVg8ubTjnFsH3KsgfhQpPRjLmxhRm0ogES4rgVt0=

POSTGRES_USER=n8n
POSTGRES_PASSWORD=n8n_secure_password_2024
POSTGRES_DB=n8n
POSTGRES_HOST=postgres

GENERIC_TIMEZONE=Africa/Cairo

BITBUCKET_WORKSPACE=acmecorp
BITBUCKET_REPO=my-project
BITBUCKET_DEFAULT_BRANCH=main

JIRA_URL=https://acmecorp.atlassian.net
```

---

## 🚀 STEP 5: Start n8n

### 5.1 Start Docker containers

```bash
cd /Users/mohamedmamdouh/Desktop/Automation/n8n-jira-automation
docker-compose up -d
```

### 5.2 Wait for startup (~30 seconds)

```bash
# Check if containers are running
docker-compose ps

# View logs
docker-compose logs -f n8n
```

### 5.3 Access n8n

Open browser: **http://localhost:5678**

---

## 🔑 STEP 6: Configure Credentials in n8n

### 6.1 First-time Setup

When you access n8n for the first time:
1. Create owner account:
   - Email: `your-email@company.com`
   - Password: Choose a strong password
   - First name / Last name

2. Click **Continue**

### 6.2 Add Jira Credentials

1. Click **Settings** (⚙️ icon) → **Credentials**
2. Click **Add Credential**
3. Search for: `Jira Software Cloud`
4. Fill in:
   ```
   Credential Name: Jira Account
   Jira URL: https://yourcompany.atlassian.net
   Email: your-email@company.com
   API Token: [paste your Jira API token]
   ```
5. Click **Save**

### 6.3 Add Bitbucket Credentials

1. Click **Add Credential** again
2. Search for: `HTTP Basic Auth`
3. Fill in:
   ```
   Credential Name: Bitbucket Credentials
   Username: your-bitbucket-username
   Password: [paste your Bitbucket app password]
   ```
4. Click **Save**

---

## 🧪 STEP 7: Test Credentials

### 7.1 Test Jira Connection

1. Go to **Workflows** → **Add Workflow**
2. Add a **Jira** node
3. Select **Get All** operation
4. Choose your **Jira Account** credential
5. Click **Execute Node**
6. Should see your Jira issues ✅

### 7.2 Test Bitbucket Connection

You'll test this when running the full workflow.

---

## 📊 Credentials Summary Checklist

Before proceeding, verify you have:

- [x] Jira URL saved in .env
- [x] Jira API token created
- [x] Jira credentials added in n8n
- [x] Bitbucket workspace/repo saved in .env
- [x] Bitbucket app password created
- [x] Bitbucket credentials added in n8n
- [x] n8n running at http://localhost:5678
- [x] Docker containers healthy

---

## 🎯 Next Steps

Now you're ready to:

1. **Import the workflow:**
   - Workflows → Import from File
   - Select: `workflows/jira-task-automation.json`

2. **Test the automation:**
   - Assign yourself a task in Jira
   - Run the workflow
   - Check results!

---

## ❓ Troubleshooting

### Can't create Jira API token?

- You need Atlassian account access
- Admin might need to enable API access
- Contact your Jira administrator

### Can't create Bitbucket app password?

- Check if you have repository access
- You need at least "Write" permission
- Two-factor authentication might be required

### n8n won't connect to Jira?

- Verify URL format: `https://company.atlassian.net` (no trailing slash)
- Check email is exact match with Jira account
- Regenerate API token if needed

### Bitbucket branch creation fails?

- Verify workspace and repository names
- Check app password has "Write" permission
- Ensure default branch exists

---

## 🔒 Security Reminders

- ✅ Never commit `.env` file to git (already in .gitignore)
- ✅ Store API tokens in password manager
- ✅ Rotate credentials every 90 days
- ✅ Use app passwords, not account passwords
- ✅ Limit permissions to what's needed

---

**Need help? Check the troubleshooting docs or ask!** 🆘
