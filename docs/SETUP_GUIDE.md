# Complete Setup Guide - n8n Jira Automation

This guide will walk you through setting up the entire automation system from scratch.

---

## 📋 Prerequisites

Before starting, ensure you have:

- ✅ Docker and Docker Compose installed
- ✅ Jira Cloud account with admin access
- ✅ Bitbucket repository access
- ✅ Rovo AI enabled (Jira Premium/Enterprise)
- ✅ Port 5678 available on your machine

---

## 🚀 Step-by-Step Setup

### Step 1: Project Setup (2 minutes)

```bash
# Navigate to the project folder
cd n8n-jira-automation

# Create environment file from template
cp .env.example .env
```

### Step 2: Configure Environment Variables (3 minutes)

Edit the `.env` file:

```bash
nano .env
# or use your preferred editor: code .env, vim .env, etc.
```

**Required changes:**

1. **Generate encryption key:**
   ```bash
   openssl rand -base64 32
   ```
   Copy the output and paste it as `N8N_ENCRYPTION_KEY`

2. **Set secure database password:**
   Replace `CHANGE_THIS_SECURE_PASSWORD` with a strong password

3. **Set your timezone:**
   Change `Africa/Cairo` to your timezone (e.g., `America/New_York`, `Europe/London`)

**Example `.env` file:**
```env
N8N_PORT=5678
N8N_PROTOCOL=http
N8N_HOST=localhost
N8N_ENCRYPTION_KEY=xK8mQ3zR5vN9pL2wY7sT4uH6jF1gD0aE=
POSTGRES_USER=n8n
POSTGRES_PASSWORD=MySecure_Password_2024!
POSTGRES_DB=n8n
POSTGRES_HOST=postgres
GENERIC_TIMEZONE=America/New_York
```

### Step 3: Start n8n (5 minutes)

```bash
# Start services in detached mode
docker-compose up -d

# Check if containers are running
docker-compose ps

# View logs (optional)
docker-compose logs -f n8n
```

**Expected output:**
```
✔ Container n8n-postgres  Started
✔ Container n8n          Started
```

### Step 4: Access n8n Interface (1 minute)

1. Open browser: http://localhost:5678
2. Create your owner account (first-time setup):
   - Email: your-email@example.com
   - Password: Choose a strong password
   - First name & Last name

### Step 5: Configure Jira Credentials (5 minutes)

#### Create Jira API Token

1. Go to: https://id.atlassian.com/manage-profile/security/api-tokens
2. Click **Create API token**
3. Name it: `n8n-automation`
4. Copy the token (you won't see it again!)

#### Add Credentials in n8n

1. In n8n, go to **Settings** (gear icon) → **Credentials**
2. Click **Add Credential**
3. Search for "Jira Software Cloud"
4. Fill in:
   - **Credential Name**: `Jira Account`
   - **Jira URL**: `https://yourcompany.atlassian.net`
   - **Email**: Your Jira email address
   - **API Token**: Paste the token you created
5. Click **Save**

### Step 6: Configure Bitbucket Credentials (5 minutes)

#### Create Bitbucket App Password

1. Go to: https://bitbucket.org/account/settings/app-passwords/
2. Click **Create app password**
3. Label: `n8n-automation`
4. Permissions: Select **Repositories: Write**
5. Click **Create**
6. Copy the password

#### Add Credentials in n8n

1. In n8n, go to **Settings** → **Credentials**
2. Click **Add Credential**
3. Search for "HTTP Basic Auth"
4. Fill in:
   - **Credential Name**: `Bitbucket Credentials`
   - **Username**: Your Bitbucket username
   - **Password**: Paste the app password
5. Click **Save**

**Also add to `.env` file:**
```env
BITBUCKET_WORKSPACE=your-workspace-name
BITBUCKET_REPO=your-repository-name
BITBUCKET_DEFAULT_BRANCH=main
```

Restart n8n:
```bash
docker-compose restart n8n
```

### Step 7: Import Workflow (2 minutes)

1. In n8n, click **Workflows** in the sidebar
2. Click **Add Workflow** → **Import from File**
3. Select: `workflows/jira-task-automation.json`
4. The workflow will open in the editor

### Step 8: Configure Workflow Credentials (3 minutes)

The workflow should automatically detect your credentials. If not:

1. Click on each **Jira node** (green boxes)
2. In the right panel, select **Jira Account** from dropdown
3. Click on each **HTTP Request node** related to Bitbucket
4. Select **Bitbucket Credentials**

### Step 9: Activate Workflow (1 minute)

1. Click **Activate** toggle in top-right (should turn blue/green)
2. The workflow is now ready!

---

## 🧪 Testing Your Setup

### Test 1: Verify Jira Connection

1. Create a test task in Jira and assign it to yourself:
   - Type: Story or Task
   - Summary: "Test API Integration"
   - Assign to: You

### Test 2: Run Workflow

1. In n8n workflow editor, click **Execute Workflow** button
2. Watch the nodes light up as they execute
3. Check for green checkmarks ✅

### Test 3: Verify Results

Check Jira:
- ✅ Subtasks created under your task
- ✅ Subtasks assigned to you
- ✅ Time estimates added

Check Bitbucket:
- ✅ New branch created: `feature/[name]-TASKKEY`

---

## 🔍 Verifying Rovo AI Integration

### Check if Rovo AI is Available

1. Go to your Jira instance
2. Navigate to **Settings** → **Products** → **Atlassian Intelligence**
3. Verify it's enabled

### Rovo AI API Endpoint

The workflow uses:
```
POST https://yourcompany.atlassian.net/rest/api/3/llm/analyze
```

**Note:** If Rovo AI API is not available, the workflow will automatically fall back to rule-based logic.

### Alternative: Use HTTP Request with Rovo

If direct API doesn't work, you can use Jira's AI assistant through:
1. Jira Automation (built-in)
2. Custom Rovo Agent API (requires Enterprise)

---

## ⚙️ Customization Options

### Adjust Branch Naming

Edit the "Extract Feature Name" node:
```javascript
// Current format: feature/[featurename]-storyticket
const branchName = `feature/${featureName}-${taskKey}`;

// Other examples:
// const branchName = `feat/${taskKey}-${featureName}`;
// const branchName = `dev/${taskKey}`;
```

### Modify AI Prompts

Edit the "Rovo AI: Break Down Task" node:
```javascript
prompt: "Break down this task into [3-7] subtasks..."
// Change to:
prompt: "Break down this task into [4-6] development subtasks with technical details..."
```

### Change Default Estimation

Edit the "Calculate Estimation" fallback section:
```javascript
const complexityMap = {
  'low': 2,    // Change to your preferred hours
  'medium': 4,
  'high': 8
};
```

---

## 🛠️ Troubleshooting

### Problem: n8n won't start

```bash
# Check if port 5678 is in use
lsof -i :5678

# View detailed logs
docker-compose logs n8n

# Restart services
docker-compose down
docker-compose up -d
```

### Problem: Database connection failed

```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Restart database
docker-compose restart postgres
```

### Problem: Jira API authentication failed

- Verify API token is correct
- Check email address matches Jira account
- Ensure Jira URL has correct format: `https://domain.atlassian.net`

### Problem: Bitbucket branch creation fails

- Verify workspace and repository names in `.env`
- Check app password has **Write** permission
- Ensure default branch exists (`main` or `master`)

### Problem: Rovo AI not responding

- Verify Atlassian Intelligence is enabled
- Check Jira plan (Premium/Enterprise required)
- Workflow will automatically use fallback logic

---

## 📊 Monitoring & Maintenance

### View Execution History

1. In n8n, go to **Executions** tab
2. See all past workflow runs
3. Click any execution to see details

### Backup Workflows

```bash
# Manual backup
./scripts/backup-workflows.sh

# Or copy from Docker volume
docker cp n8n:/home/node/.n8n/workflows ./backups/
```

### Update n8n

```bash
# Pull latest image
docker-compose pull n8n

# Restart with new version
docker-compose up -d
```

---

## 🎯 Next Steps

After successful setup:

1. ✅ Test with real tasks
2. ✅ Adjust AI prompts for your needs
3. ✅ Customize estimation rules
4. ✅ Add notifications (optional)
5. ✅ Create more automations

---

## 🆘 Need Help?

- **Documentation**: See `docs/TROUBLESHOOTING.md`
- **n8n Community**: https://community.n8n.io
- **Jira API Docs**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/

**Congratulations! Your automation is ready to use!** 🎉
