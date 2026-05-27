# Troubleshooting Guide

Common issues and solutions for n8n Jira Automation.

---

## 🚨 Docker & n8n Issues

### n8n Container Won't Start

**Symptoms:**
- `docker-compose up -d` fails
- Container exits immediately

**Solutions:**

```bash
# Check logs
docker-compose logs n8n

# Common fixes:
# 1. Port already in use
lsof -i :5678
# Kill process or change N8N_PORT in .env

# 2. Permission issues
sudo chown -R $USER:$USER ./n8n-data

# 3. Corrupted encryption key
# Generate new key in .env:
openssl rand -base64 32

# 4. Database connection failed
docker-compose restart postgres
docker-compose up -d n8n
```

### PostgreSQL Connection Failed

**Symptoms:**
- n8n shows database error
- "Connection refused"

**Solutions:**

```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Verify credentials match in .env
cat .env | grep POSTGRES

# Reset database (⚠️ loses data)
docker-compose down -v
docker-compose up -d

# Check database logs
docker-compose logs postgres
```

### Can't Access n8n UI

**Symptoms:**
- http://localhost:5678 not loading
- Connection timeout

**Solutions:**

```bash
# 1. Check container is running
docker-compose ps

# 2. Verify port mapping
docker port n8n

# 3. Check firewall
# macOS:
sudo pfctl -d  # disable temporarily

# Linux:
sudo ufw allow 5678

# 4. Try different browser or incognito mode

# 5. Check n8n logs
docker-compose logs -f n8n
```

---

## 🔐 Authentication Issues

### Jira API Authentication Failed

**Symptoms:**
- "401 Unauthorized"
- "Invalid credentials"

**Solutions:**

1. **Verify Email Address**
   ```bash
   # Must match exactly with Jira account
   # Check in: https://id.atlassian.com/manage-profile
   ```

2. **Regenerate API Token**
   - Go to: https://id.atlassian.com/manage-profile/security/api-tokens
   - Delete old token
   - Create new token
   - Update in n8n credentials

3. **Check Jira URL Format**
   ```
   ✅ Correct: https://yourcompany.atlassian.net
   ❌ Wrong: http://yourcompany.atlassian.net (no https)
   ❌ Wrong: https://yourcompany.atlassian.net/ (trailing slash)
   ❌ Wrong: yourcompany.atlassian.net (no protocol)
   ```

4. **Test with curl**
   ```bash
   curl -u your-email@company.com:YOUR_API_TOKEN \
     https://yourcompany.atlassian.net/rest/api/3/myself
   ```

### Bitbucket Authentication Failed

**Symptoms:**
- "403 Forbidden"
- "Invalid app password"

**Solutions:**

1. **Check App Password Permissions**
   - Go to: https://bitbucket.org/account/settings/app-passwords/
   - Verify "Repositories: Write" is checked
   - Regenerate if needed

2. **Verify Username (not email)**
   ```
   ✅ Correct: john-doe (username)
   ❌ Wrong: john@company.com (email)
   ```

3. **Check Workspace/Repo Names**
   ```bash
   # From URL: https://bitbucket.org/acmecorp/my-project
   BITBUCKET_WORKSPACE=acmecorp
   BITBUCKET_REPO=my-project
   ```

4. **Test with curl**
   ```bash
   curl -u your-username:YOUR_APP_PASSWORD \
     https://api.bitbucket.org/2.0/repositories/WORKSPACE/REPO
   ```

---

## 🤖 Rovo AI Issues

### Rovo AI Not Responding

**Symptoms:**
- "AI service unavailable"
- Workflow uses fallback logic

**Solutions:**

1. **Verify Rovo is Enabled**
   - Login to Jira as admin
   - Settings → Products → Atlassian Intelligence
   - Enable if disabled

2. **Check Jira Plan**
   - Rovo requires Premium or Enterprise
   - Verify in: Settings → Billing

3. **API Endpoint Not Available**
   ```bash
   # Test Rovo API
   curl -X POST \
     -u email:token \
     -H "Content-Type: application/json" \
     -d '{"prompt":"test"}' \
     https://yourcompany.atlassian.net/rest/api/3/llm/analyze
   ```

4. **Use Fallback (Automatic)**
   - Workflow automatically uses rule-based logic
   - No action needed
   - Check "Fallback: Rule-Based Breakdown" node executes

### AI Responses Are Poor Quality

**Solutions:**

1. **Improve AI Prompts**
   - Edit "Rovo AI: Break Down Task" node
   - Make prompts more specific:
   ```javascript
   // Generic
   "Break down this task into subtasks"
   
   // Better
   "Break down this task into 4-6 development subtasks. 
   Include: backend API, frontend UI, testing, documentation. 
   Format as JSON array."
   ```

2. **Adjust Task Descriptions**
   - Provide detailed Jira task descriptions
   - Include acceptance criteria
   - Mention technologies used

3. **Fine-tune Fallback Rules**
   - Edit "Fallback: Rule-Based Breakdown" node
   - Add keywords for your domain

---

## 🔄 Workflow Execution Issues

### "No Tasks Found"

**Symptoms:**
- Workflow completes but no subtasks created
- "Get My Assigned Tasks" returns empty

**Solutions:**

1. **Check JQL Filter**
   ```javascript
   // Current filter
   assignee = currentUser() AND parent is EMPTY AND resolution = Unresolved
   
   // Debug: Try simpler filter
   assignee = currentUser()
   ```

2. **Verify Task Assignment**
   - Ensure tasks are assigned to YOU
   - Check task is unresolved
   - Verify task is a parent (not already a subtask)

3. **Test JQL in Jira**
   - Go to Jira → Filters → Advanced
   - Paste JQL query
   - Verify results show

### Subtasks Not Created

**Symptoms:**
- Workflow completes successfully
- No subtasks appear in Jira

**Solutions:**

1. **Check Execution Logs**
   - In n8n: Executions tab
   - Click failed execution
   - Check "Create Subtask in Jira" node

2. **Verify Project Permissions**
   - Ensure you can manually create subtasks
   - Project settings → Permissions
   - Check "Create Issues" permission

3. **Check Issue Type**
   - Verify "Sub-task" issue type exists
   - Project settings → Issue types
   - Enable if disabled

4. **Review Error Messages**
   ```javascript
   // Common errors:
   // - "Field 'parent' is not valid"
   // - "Issue type 'Sub-task' does not exist"
   ```

### Branch Not Created in Bitbucket

**Symptoms:**
- Subtasks created successfully
- No branch in Bitbucket

**Solutions:**

1. **Check Branch Already Exists**
   ```bash
   # In Bitbucket, search for branch name
   feature/your-feature-PROJ-123
   ```

2. **Verify Default Branch**
   ```bash
   # In .env
   BITBUCKET_DEFAULT_BRANCH=main  # or master, develop
   ```

3. **Check Repository Permissions**
   - Verify app password has Write access
   - Check you have push rights to repo

4. **Review Branch Naming**
   - Edit "Extract Feature Name" node
   - Check for invalid characters
   - Branch names can't have: spaces, special chars

---

## ⚡ Performance Issues

### Workflow Takes Too Long

**Symptoms:**
- Execution time > 5 minutes
- Timeouts

**Solutions:**

1. **Reduce AI Calls**
   - Use fallback for estimation
   - Disable AI for simple tasks

2. **Batch Processing**
   - Limit tasks per execution
   - Add pagination to Jira query:
   ```javascript
   maxResults: 5  // Process 5 tasks at a time
   ```

3. **Optimize HTTP Requests**
   - Increase timeout values
   - Add retry logic

### High API Rate Limits

**Symptoms:**
- "Rate limit exceeded"
- 429 error codes

**Solutions:**

1. **Add Delays**
   - Insert "Wait" nodes between API calls
   - Delay: 1-2 seconds

2. **Reduce Frequency**
   - Don't trigger too often
   - Process tasks in batches

3. **Contact Support**
   - Request higher limits from Atlassian

---

## 🔍 Debugging Techniques

### Enable Debug Mode

```bash
# Edit docker-compose.yml
environment:
  - N8N_LOG_LEVEL=debug

# Restart
docker-compose restart n8n

# View logs
docker-compose logs -f n8n
```

### Test Individual Nodes

1. In n8n workflow editor
2. Click node to test
3. Click "Execute Node" (play button)
4. View input/output in right panel

### Use Code Node for Debugging

```javascript
// Add Code node after problem node
console.log('Input data:', $input.all());
console.log('Item:', $json);
return $input.all();
```

### Export Execution Data

1. Go to Executions tab
2. Click execution
3. Download JSON
4. Analyze offline

---

## 📋 Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `ECONNREFUSED` | Service not running | Restart containers |
| `401 Unauthorized` | Invalid credentials | Regenerate API tokens |
| `404 Not Found` | Wrong URL/endpoint | Check URLs in .env |
| `429 Too Many Requests` | Rate limited | Add delays between calls |
| `500 Internal Server Error` | API issue | Check service status, retry |
| `ETIMEDOUT` | Network timeout | Increase timeout values |
| `Invalid JSON` | Parsing error | Check AI response format |

---

## 🛠️ Maintenance Commands

### Restart Everything

```bash
docker-compose down
docker-compose up -d
```

### Clear All Data (⚠️ Destructive)

```bash
docker-compose down -v
rm -rf n8n-data postgres-data
docker-compose up -d
```

### Backup Workflows

```bash
# Manual backup
docker cp n8n:/home/node/.n8n/workflows ./backups/

# Or use script
./scripts/backup-workflows.sh
```

### View Container Stats

```bash
docker stats n8n postgres
```

### Update n8n Version

```bash
docker-compose pull
docker-compose up -d
```

---

## 🆘 Still Having Issues?

### Check Resources

1. **n8n Documentation**: https://docs.n8n.io
2. **n8n Community**: https://community.n8n.io
3. **Jira API Docs**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/
4. **Bitbucket API Docs**: https://developer.atlassian.com/cloud/bitbucket/rest/

### Get Help

1. **Export workflow**: Workflows → Export
2. **Export execution**: Executions → Download JSON
3. **Share anonymized versions** in n8n community
4. **Include**:
   - Error messages
   - Logs (remove sensitive data)
   - Steps to reproduce

---

## 📞 Quick Reference

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Restart n8n only
docker-compose restart n8n

# Access n8n shell
docker exec -it n8n sh

# Check running containers
docker-compose ps

# Remove all data
docker-compose down -v
```

---

**Need more help? Check [SETUP_GUIDE.md](SETUP_GUIDE.md) or [CREDENTIALS_SETUP.md](CREDENTIALS_SETUP.md)**
