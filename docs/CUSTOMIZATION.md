# Customization Guide

Learn how to customize the workflow for your specific needs.

---

## 🎨 Common Customizations

### 1. Branch Naming Convention

**Location:** "Extract Feature Name" node

**Current format:** `feature/[featurename]-storyticket`

**Examples:**

```javascript
// Option 1: Ticket-first format
const branchName = `feature/${taskKey}-${featureName}`;
// Result: feature/PROJ-123-add-login-page

// Option 2: Type-based prefixes
const type = parentTask.fields.issuetype.name.toLowerCase();
const prefix = type === 'bug' ? 'bugfix' : 'feature';
const branchName = `${prefix}/${featureName}-${taskKey}`;
// Result: bugfix/fix-login-error-PROJ-123

// Option 3: Simple format
const branchName = `dev/${taskKey}`;
// Result: dev/PROJ-123

// Option 4: Include sprint info
const sprint = parentTask.fields.sprint?.name || 'backlog';
const branchName = `${sprint}/${taskKey}-${featureName}`;
// Result: sprint-24/PROJ-123-add-login-page
```

---

### 2. Subtask Breakdown Rules

**Location:** "Fallback: Rule-Based Breakdown" node

**Add your own keyword patterns:**

```javascript
const summary = parentTask.fields.summary.toLowerCase();
const description = (parentTask.fields.description || '').toLowerCase();

// Custom patterns for your domain
if (summary.includes('mobile') || summary.includes('ios') || summary.includes('android')) {
  subtasks = [
    { title: 'Design mobile UI/UX', complexity: 'medium' },
    { title: 'Implement for iOS', complexity: 'high' },
    { title: 'Implement for Android', complexity: 'high' },
    { title: 'Test on multiple devices', complexity: 'medium' },
    { title: 'Update mobile documentation', complexity: 'low' }
  ];
} 
else if (summary.includes('database') || summary.includes('migration')) {
  subtasks = [
    { title: 'Design schema changes', complexity: 'high' },
    { title: 'Write migration script', complexity: 'medium' },
    { title: 'Test migration on staging', complexity: 'medium' },
    { title: 'Create rollback plan', complexity: 'low' },
    { title: 'Update data documentation', complexity: 'low' }
  ];
}
else if (summary.includes('integration') || summary.includes('third-party')) {
  subtasks = [
    { title: 'Research API/SDK requirements', complexity: 'low' },
    { title: 'Setup authentication', complexity: 'medium' },
    { title: 'Implement integration logic', complexity: 'high' },
    { title: 'Add error handling', complexity: 'medium' },
    { title: 'Write integration tests', complexity: 'medium' }
  ];
}
// ... add more patterns
```

---

### 3. Time Estimation Rules

**Location:** "Calculate Estimation" node

**Customize default hours:**

```javascript
// Simple: Based on complexity
const complexityMap = {
  'low': 2,      // 2 hours
  'medium': 5,   // 5 hours  
  'high': 10     // 10 hours (1.25 days)
};

// Advanced: Based on keywords
function estimateByKeywords(title, complexity) {
  const titleLower = title.toLowerCase();
  
  // Override estimates for specific tasks
  if (titleLower.includes('research') || titleLower.includes('investigation')) {
    return 3;
  }
  if (titleLower.includes('documentation')) {
    return 1;
  }
  if (titleLower.includes('testing') || titleLower.includes('qa')) {
    return 2;
  }
  if (titleLower.includes('design') || titleLower.includes('architecture')) {
    return 4;
  }
  if (titleLower.includes('implementation') || titleLower.includes('develop')) {
    return complexity === 'high' ? 8 : 5;
  }
  
  // Default to complexity map
  return complexityMap[complexity] || 4;
}

const estimationHours = estimateByKeywords(subtask.title, subtask.complexity);
```

---

### 4. AI Prompts for Better Results

**Location:** "Rovo AI: Break Down Task" node

**Improve prompts for your context:**

```javascript
// Generic prompt (current)
const prompt = "Break down this Jira task into 3-7 logical subtasks...";

// Specific for web development
const prompt = `
You are a senior software engineer. Break down this task into 4-7 development subtasks.

Task: ${taskKey} - ${summary}
Description: ${description}

Requirements:
- Include backend, frontend, and testing subtasks
- Each subtask should be completable in 2-8 hours
- Use clear, actionable titles
- Assign complexity: low (< 2h), medium (2-5h), high (> 5h)

Return ONLY valid JSON array:
[
  {"title": "Setup API endpoint", "description": "Create REST endpoint...", "complexity": "medium"},
  ...
]
`;

// Specific for DevOps tasks
const prompt = `
Break down this DevOps task into deployment subtasks.

Task: ${summary}

Focus on:
- Infrastructure setup
- CI/CD pipeline changes
- Monitoring and alerts
- Documentation

Return JSON array with title, description, complexity.
`;
```

---

### 5. JQL Filters for Different Scenarios

**Location:** "Get My Assigned Tasks" node

**Customize task selection:**

```javascript
// Current: Only unresolved parent tasks assigned to you
jql: "assignee = currentUser() AND parent is EMPTY AND resolution = Unresolved"

// Option 1: Specific project
jql: "project = MYPROJ AND assignee = currentUser() AND parent is EMPTY AND resolution = Unresolved"

// Option 2: Include specific issue types
jql: "assignee = currentUser() AND issuetype in (Story, Task) AND parent is EMPTY AND resolution = Unresolved"

// Option 3: Only tasks in current sprint
jql: "assignee = currentUser() AND sprint in openSprints() AND parent is EMPTY AND resolution = Unresolved"

// Option 4: Tasks with specific label
jql: "assignee = currentUser() AND labels = 'needs-breakdown' AND parent is EMPTY"

// Option 5: High priority only
jql: "assignee = currentUser() AND priority in (Highest, High) AND parent is EMPTY AND resolution = Unresolved"

// Option 6: Created recently
jql: "assignee = currentUser() AND created >= -7d AND parent is EMPTY AND resolution = Unresolved"
```

---

### 6. Add Notifications

**Add node after "Success Summary"**

#### Slack Notification

```javascript
// Add Slack node
{
  "parameters": {
    "channel": "#dev-notifications",
    "text": "=✅ Jira Automation Complete\n\nTasks processed: {{ $json.stats.tasksProcessed }}\nSubtasks created: {{ $json.stats.subtasksCreated }}\nBranches: {{ $json.stats.branchesCreated }}",
    "otherOptions": {
      "username": "n8n Bot"
    }
  },
  "name": "Notify Slack",
  "type": "n8n-nodes-base.slack"
}
```

#### Email Notification

```javascript
// Add Send Email node
{
  "parameters": {
    "fromEmail": "automation@company.com",
    "toEmail": "you@company.com",
    "subject": "Jira Automation Completed",
    "emailFormat": "html",
    "text": "=<h2>✅ Automation Summary</h2>\n<ul>\n<li>Tasks: {{ $json.stats.tasksProcessed }}</li>\n<li>Subtasks: {{ $json.stats.subtasksCreated }}</li>\n<li>Branches: {{ $json.stats.branchesCreated }}</li>\n</ul>"
  },
  "name": "Send Email",
  "type": "n8n-nodes-base.emailSend"
}
```

---

### 7. Schedule Automation (Auto-trigger)

**Replace "Manual Trigger" with "Cron" node:**

```javascript
{
  "parameters": {
    "rule": {
      "interval": [
        {
          "field": "cronExpression",
          "expression": "0 9 * * 1-5"  // 9 AM, Monday-Friday
        }
      ]
    }
  },
  "name": "Schedule Daily",
  "type": "n8n-nodes-base.cron"
}

// Other schedule examples:
// Every hour: "0 * * * *"
// Twice daily: "0 9,17 * * 1-5"
// Every Monday: "0 9 * * 1"
```

---

### 8. Add Custom Fields to Subtasks

**Location:** "Create Subtask in Jira" node

```javascript
{
  "parameters": {
    "additionalFields": {
      "description": "={{ $json.description }}",
      "parent": "={{ $json.parentKey }}",
      "timetracking": {
        "originalEstimate": "={{ $json.estimationHours }}h"
      },
      // Add custom fields
      "customFields": {
        "customfield_10001": "Backend",  // Component
        "customfield_10002": "High",     // Story Points
        "customfield_10003": {           // Sprint
          "id": "123"
        }
      },
      "labels": ["auto-generated", "subtask"],
      "priority": {
        "name": "Medium"
      }
    }
  }
}
```

**Find custom field IDs:**
```bash
curl -u email:token \
  https://yourcompany.atlassian.net/rest/api/3/field
```

---

### 9. Filter Tasks by Labels/Status

**Add node after "Get My Assigned Tasks":**

```javascript
// Code node to filter
{
  "parameters": {
    "jsCode": `
      const tasks = $input.all();
      
      // Filter logic
      const filtered = tasks.filter(task => {
        const labels = task.json.fields.labels || [];
        const status = task.json.fields.status.name;
        
        // Only tasks with 'ready' label and 'To Do' status
        return labels.includes('ready') && status === 'To Do';
      });
      
      return filtered;
    `
  },
  "name": "Filter by Labels",
  "type": "n8n-nodes-base.code"
}
```

---

### 10. Multiple Branch Creation

**Create branches in multiple repos:**

```javascript
// After "Extract Feature Name" node
// Add Split In Batches for repos

const repos = [
  'frontend-repo',
  'backend-repo',
  'mobile-app'
];

repos.forEach(repo => {
  // Create branch in each repo
  // HTTP Request to Bitbucket API
});
```

---

## 🧪 Testing Customizations

### Test Locally

1. **Clone workflow**
   - Duplicate workflow in n8n
   - Name it "TEST - Jira Automation"

2. **Modify test workflow**
   - Make your changes

3. **Test with mock data**
   - Use "Set" node to inject test data
   - Don't trigger real Jira/Bitbucket calls

4. **Verify results**
   - Check each node output
   - Fix issues

5. **Apply to production**
   - Copy changes to main workflow

---

## 📦 Advanced Customizations

### 1. Add Error Handling

```javascript
// Wrap critical nodes in Try-Catch
{
  "parameters": {
    "jsCode": `
      try {
        // Your logic here
        const result = performOperation();
        return [{ json: result }];
      } catch (error) {
        // Log error
        console.error('Operation failed:', error);
        
        // Return fallback or re-throw
        return [{ 
          json: { 
            error: true, 
            message: error.message 
          } 
        }];
      }
    `
  }
}
```

### 2. Parallel Processing

Process multiple tasks simultaneously:

```javascript
// Use Split In Batches with batch size > 1
{
  "parameters": {
    "batchSize": 3,  // Process 3 tasks at once
    "options": {}
  }
}
```

### 3. Conditional Branch Creation

Only create branches for certain tasks:

```javascript
// Add IF node before "Create Bitbucket Branch"
{
  "parameters": {
    "conditions": {
      "string": [
        {
          "value1": "={{ $json.fields.issuetype.name }}",
          "operation": "equals",
          "value2": "Story"
        }
      ]
    }
  },
  "name": "Only Create Branch for Stories"
}
```

---

## 💡 Best Practices

1. **Test changes incrementally** - One modification at a time
2. **Backup before major changes** - Export workflow JSON
3. **Use descriptive node names** - Easy to debug
4. **Add comments in Code nodes** - Document your logic
5. **Monitor execution history** - Check for patterns/errors
6. **Version control workflows** - Save exports in git

---

## 🆘 Need Help?

Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) if customizations don't work as expected.

**Happy customizing!** 🚀
