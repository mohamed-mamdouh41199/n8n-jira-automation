# n8n Jira Automation - Detailed Project Plan

## 📋 Project Overview
Automate your Jira task management workflow with intelligent subtask creation, AI-powered estimation, and automatic Bitbucket branch creation.

---

## 🎯 Automation Goals

### What This Automation Will Do:
1. **Fetch Assigned Tasks** - Query Jira for all tasks currently assigned to you
2. **Intelligent Task Breakdown** - Use AI to break main tasks into logical subtasks
3. **Smart Estimation** - AI analyzes subtasks and provides time estimates (with fallback logic)
4. **Auto-Assignment** - Automatically assign all created subtasks to you
5. **Branch Creation** - Create Bitbucket feature branch: `feature/[featurename]-storyticket`

---

## 🏗️ Implementation Plan

### Phase 1: Environment Setup (15-20 minutes)

#### 1.1 Docker Setup
**What I'll create:**
- `docker-compose.yml` - n8n + PostgreSQL database configuration
- `.env.example` - Template for environment variables
- `README.md` - Setup instructions

**What you'll need to provide:**
- Server/machine with Docker installed
- Ports 5678 (n8n UI) available

#### 1.2 Configuration Files
**Files to create:**
- `.gitignore` - Protect sensitive data
- `credentials-template.json` - Guide for API credentials setup

---

### Phase 2: Workflow Development

#### 2.1 Main Workflow Structure
**Workflow Name:** `Jira Task Automation - Main Flow`

**Nodes & Logic:**

```
[Manual Trigger]
    ↓
[Jira: Get My Assigned Tasks]
    ↓
[Filter: Only Parent Tasks]
    ↓
[Loop: For Each Task]
    ↓
    ├─> [AI Agent: Break Down Task]
    │       ↓
    │   [Validate AI Response]
    │       ↓
    │   [IF: AI Success?]
    │       ├─ Yes → [Parse AI Subtasks]
    │       └─ No → [Fallback: Manual Breakdown Rules]
    │           ↓
    ├─> [AI Agent: Estimate Subtasks]
    │       ↓
    │   [IF: AI Estimation Success?]
    │       ├─ Yes → [Use AI Estimates]
    │       └─ No → [Fallback: Default 2h per subtask]
    │           ↓
    ├─> [Loop: Create Each Subtask]
    │       ↓
    │   [Jira: Create Subtask]
    │       ↓
    │   [Jira: Assign to You]
    │       ↓
    │   [Jira: Set Estimation]
    │           ↓
    └─> [Extract Feature Name]
            ↓
        [Bitbucket: Create Branch]
            ↓
    [Send Success Notification]
        ↓
    [End]
```

#### 2.2 AI Integration Details

**AI Model Options:**
- **Primary:** OpenAI GPT-4 (most reliable)
- **Alternative:** Anthropic Claude 3.5
- **Fallback:** Rule-based logic (no AI needed)

**AI Prompts I'll Design:**

1. **Task Breakdown Prompt:**
   ```
   Analyze this Jira task and break it into 3-7 logical subtasks.
   Task: [title + description]
   Return JSON: [{"title": "...", "description": "...", "complexity": "low|medium|high"}]
   ```

2. **Estimation Prompt:**
   ```
   Estimate time for each subtask in hours (0.5 to 16h range).
   Subtasks: [list]
   Return JSON: [{"subtask": "...", "hours": X, "reasoning": "..."}]
   ```

**Fallback Logic:**
- If AI fails → Use keyword-based rules (frontend=4h, backend=6h, testing=2h, etc.)
- If rules fail → Default 2 hours per subtask

#### 2.3 API Integrations

**Required Credentials:**
1. **Jira:**
   - Instance URL (e.g., `yourcompany.atlassian.net`)
   - Email address
   - API Token (I'll guide you to create this)

2. **Bitbucket:**
   - Workspace name
   - Repository name
   - App password or personal token

3. **AI Service (choose one):**
   - OpenAI API Key OR
   - Anthropic API Key OR
   - Skip for fallback-only mode

---

### Phase 3: Error Handling & Reliability

#### 3.1 Error Scenarios Covered:
- ✅ No tasks assigned to you
- ✅ AI service timeout/failure
- ✅ Jira API rate limits
- ✅ Bitbucket branch already exists
- ✅ Invalid task format
- ✅ Network connectivity issues

#### 3.2 Notifications:
- Success summary (tasks processed, subtasks created, branches created)
- Error alerts with actionable details
- Optional: Slack/Email notifications (can add later)

---

### Phase 4: Testing & Validation

#### 4.1 Test Workflow
**What I'll create:**
- Test workflow with mock data
- Validation checklist
- Troubleshooting guide

#### 4.2 Test Scenarios:
1. Single task with simple description
2. Multiple tasks assigned
3. AI service unavailable (test fallback)
4. Duplicate branch name handling
5. Empty/incomplete task data

---

## 📦 Deliverables

### Files I Will Create:

```
n8n-jira-automation/
├── PROJECT_PLAN.md                 (this file)
├── README.md                       (setup guide)
├── docker-compose.yml              (n8n installation)
├── .env.example                    (configuration template)
├── .gitignore                      (security)
├── workflows/
│   ├── jira-task-automation.json  (main workflow)
│   └── test-workflow.json         (testing)
├── docs/
│   ├── SETUP_GUIDE.md             (step-by-step setup)
│   ├── CREDENTIALS_SETUP.md       (API keys guide)
│   ├── TROUBLESHOOTING.md         (common issues)
│   └── CUSTOMIZATION.md           (how to modify)
└── scripts/
    └── backup-workflows.sh         (backup utility)
```

---

## 🔧 Technical Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Automation Platform | n8n (self-hosted) | Workflow orchestration |
| Database | PostgreSQL | Store workflow data |
| Container | Docker + Docker Compose | Easy deployment |
| AI Service | OpenAI GPT-4 / Claude 3.5 | Task analysis |
| APIs | Jira REST API | Task management |
| APIs | Bitbucket REST API | Branch creation |

---

## ⏱️ Estimated Timeline

| Phase | Task | Time |
|-------|------|------|
| Setup | Docker + n8n installation | 15 min |
| Config | API credentials setup | 10 min |
| Import | Load workflow into n8n | 5 min |
| Test | Run test scenarios | 10 min |
| **Total** | **Ready to use** | **~40 min** |

---

## 🔒 Security Considerations

### What I'll Implement:
1. **Environment Variables** - No hardcoded credentials
2. **Git Ignore** - Sensitive files excluded
3. **API Token Security** - Using tokens, not passwords
4. **Local Storage** - All data stays on your server
5. **HTTPS Ready** - Configuration for SSL (optional)

---

## 🎓 Knowledge Transfer

### Documentation Included:
1. **Setup Guide** - Step-by-step with screenshots
2. **How It Works** - Explain each workflow node
3. **Customization Guide** - Modify for your needs
4. **Troubleshooting** - Common issues + solutions
5. **Best Practices** - Jira task naming, estimation tips

---

## 🔄 Future Enhancements (Optional)

Ideas we can add later:
- 📧 Email/Slack notifications
- 📊 Automated time tracking
- 🔄 Sync subtask status back to parent
- 📈 Estimation accuracy tracking
- 🎨 Custom task templates by project
- 🔀 Automatic PR creation after branch
- 🧪 Run tests before creating subtasks

---

## 📝 Prerequisites Check

Before I start, please confirm you have:
- [ ] Docker & Docker Compose installed
- [ ] Jira account with admin/API access
- [ ] Bitbucket repository access
- [ ] (Optional) OpenAI or Anthropic API key
- [ ] Port 5678 available on your machine

---

## ✅ Next Steps

Once you say **"OK"**, I will:
1. Create all files listed above
2. Write complete documentation
3. Build the n8n workflow with all logic
4. Provide you with a step-by-step setup guide
5. Include testing instructions

**Estimated total creation time:** 10-15 minutes

---

## 💡 Questions?

If you have any questions about this plan, ask now before I start building!

Otherwise, just say **"OK"** or **"Start"** and I'll begin creating everything! 🚀
