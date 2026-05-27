# n8n Jira Automation with Rovo AI

🚀 **Automate your Jira workflow** with intelligent task breakdown, AI-powered estimation using Atlassian Rovo AI, and automatic Bitbucket branch creation.

---

## 🎯 What This Does

1. **Fetches your assigned Jira tasks** (manual trigger)
2. **Uses Rovo AI** to intelligently break tasks into subtasks
3. **AI-powered estimation** with smart fallback logic
4. **Auto-assigns subtasks** to you
5. **Creates Bitbucket branches** with format: `feature/[featurename]-storyticket`

---

## ⚡ Quick Start

### Prerequisites
- Docker & Docker Compose installed
- Jira account with API access
- Bitbucket repository access
- Rovo AI enabled in Atlassian (Premium/Enterprise)
- Port 5678 available

### Installation (5 minutes)

```bash
# 1. Clone or navigate to project folder
cd n8n-jira-automation

# 2. Copy environment template
cp .env.example .env

# 3. Edit .env with your details
nano .env  # or use any text editor

# 4. Start n8n
docker-compose up -d

# 5. Access n8n UI
open http://localhost:5678
```

---

## 📋 Configuration Steps

### Step 1: Set Environment Variables

Edit `.env` file:

```bash
# n8n Configuration
N8N_PORT=5678
N8N_PROTOCOL=http
N8N_HOST=localhost

# Database
POSTGRES_USER=n8n
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_DB=n8n

# Timezone
GENERIC_TIMEZONE=Africa/Cairo
```

### Step 2: Configure Credentials in n8n

Once n8n is running, go to **Settings → Credentials** and add:

1. **Jira Software Cloud**
   - Jira URL: `https://yourcompany.atlassian.net`
   - Email: `your-email@company.com`
   - API Token: [Create here](https://id.atlassian.com/manage-profile/security/api-tokens)

2. **Bitbucket API**
   - Workspace: `your-workspace`
   - Username: `your-username`
   - App Password: [Create here](https://bitbucket.org/account/settings/app-passwords/)

3. **Atlassian Rovo AI** (via HTTP Request)
   - Uses your Jira credentials
   - Atlassian Intelligence API enabled

### Step 3: Import Workflow

1. Go to **Workflows** in n8n
2. Click **Import from File**
3. Select `workflows/jira-task-automation.json`
4. Activate the workflow

### Step 4: Test Run

1. Assign yourself a Jira task
2. Click **Execute Workflow** in n8n
3. Watch the magic happen! ✨

---

## 📚 Documentation

Detailed guides in the `docs/` folder:

- **[SETUP_GUIDE.md](docs/SETUP_GUIDE.md)** - Complete setup walkthrough
- **[CREDENTIALS_SETUP.md](docs/CREDENTIALS_SETUP.md)** - API credentials guide
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues & fixes
- **[CUSTOMIZATION.md](docs/CUSTOMIZATION.md)** - Customize for your needs

---

## 🏗️ Architecture

```
Manual Trigger → Jira API → Rovo AI → Create Subtasks → Bitbucket API
                                ↓
                         Fallback Logic (if AI fails)
```

**Technology Stack:**
- n8n (workflow automation)
- PostgreSQL (data persistence)
- Rovo AI (task intelligence)
- Jira REST API
- Bitbucket REST API

---

## 🔒 Security

- ✅ All credentials stored encrypted in PostgreSQL
- ✅ Environment variables for sensitive data
- ✅ `.gitignore` prevents credential leaks
- ✅ Self-hosted = full data control
- ✅ API tokens (not passwords)

---

## 🛠️ Maintenance

### Backup Workflows
```bash
./scripts/backup-workflows.sh
```

### View Logs
```bash
docker-compose logs -f n8n
```

### Update n8n
```bash
docker-compose pull
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

---

## 🐛 Troubleshooting

**n8n won't start?**
```bash
# Check if port is available
lsof -i :5678

# View logs
docker-compose logs n8n
```

**Workflow fails?**
- Check credentials are active
- Verify Rovo AI is enabled
- See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

---

## 🎨 Customization

Common modifications:
- Change branch naming pattern
- Adjust AI prompts
- Modify estimation rules
- Add notifications (Slack/Email)
- Custom subtask templates

See [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for details.

---

## 📞 Support

- **Documentation**: Check `docs/` folder
- **n8n Community**: https://community.n8n.io
- **Jira API**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/

---

## 📄 License

This project is open source. Use and modify as needed.

---

## 🚀 Next Steps

After setup:
1. Test with a simple task
2. Review AI-generated subtasks
3. Adjust estimation rules if needed
4. Add more workflows for other automations

**Happy automating!** 🎉
