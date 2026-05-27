# Workflow Diagram - n8n Jira Automation with Rovo AI

## 📊 Complete Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         JIRA TASK AUTOMATION FLOW                           │
└─────────────────────────────────────────────────────────────────────────────┘

                              ┌──────────────────┐
                              │  Manual Trigger  │
                              │   (You click)    │
                              └────────┬─────────┘
                                       │
                                       ▼
                           ┌────────────────────────┐
                           │  Get My Assigned Tasks │
                           │    (Jira REST API)     │
                           │  JQL: assignee = me    │
                           │  parent is EMPTY       │
                           └──────────┬─────────────┘
                                      │
                                      ▼
                         ┌─────────────────────────────┐
                         │   Filter Parent Tasks Only  │
                         │   (Exclude subtasks)        │
                         └──────────┬──────────────────┘
                                    │
                                    ▼
                        ┌────────────────────────────┐
                        │    Loop Each Task          │
                        │    (Process one by one)    │
                        └────────┬───────────────────┘
                                 │
        ┌────────────────────────┴────────────────────────┐
        │                                                  │
        ▼                                                  │
┌────────────────────────────┐                           │
│  Rovo AI: Break Down Task  │                           │
│  (Atlassian Intelligence)  │                           │
│                            │                           │
│  Prompt: "Break this task  │                           │
│  into 3-7 logical          │                           │
│  subtasks..."              │                           │
└────────┬───────────────────┘                           │
         │                                                │
         ▼                                                │
   ┌──────────────┐                                      │
   │  AI Success? │                                      │
   └──┬────────┬──┘                                      │
      │        │                                         │
   YES│        │NO (AI Failed or Timeout)                │
      │        │                                         │
      ▼        ▼                                         │
┌───────────────────┐     ┌───────────────────────────┐ │
│ Parse AI Subtasks │     │ Fallback: Rule-Based      │ │
│                   │     │ Breakdown                 │ │
│ Extract JSON:     │     │                           │ │
│ [{title, desc,    │     │ IF summary contains       │ │
│   complexity}]    │     │  - "API" → backend tasks  │ │
│                   │     │  - "UI" → frontend tasks  │ │
└────────┬──────────┘     │  - "bug" → fix tasks      │ │
         │                │ ELSE → generic breakdown  │ │
         │                └──────────┬────────────────┘ │
         │                           │                   │
         └───────────┬───────────────┘                   │
                     │                                   │
                     ▼                                   │
        ┌─────────────────────────────┐                 │
        │  For Each Subtask (Loop)    │                 │
        └──────────┬──────────────────┘                 │
                   │                                     │
                   ▼                                     │
       ┌───────────────────────────────┐                │
       │  Rovo AI: Estimate Subtask    │                │
       │  (Time in hours)               │                │
       │                                │                │
       │  Prompt: "Estimate time for   │                │
       │  this subtask. Consider        │                │
       │  complexity: [low/med/high]"   │                │
       └──────────┬─────────────────────┘                │
                  │                                      │
                  ▼                                      │
         ┌─────────────────────┐                        │
         │ Calculate Estimation │                       │
         │                      │                       │
         │ IF AI success:       │                       │
         │   Use AI hours       │                       │
         │ ELSE (Fallback):     │                       │
         │   low → 2h           │                       │
         │   medium → 4h        │                       │
         │   high → 8h          │                       │
         └──────────┬───────────┘                       │
                    │                                    │
                    ▼                                    │
        ┌─────────────────────────┐                     │
        │  Create Subtask in Jira │                     │
        │                         │                     │
        │  Fields:                │                     │
        │  - Summary (title)      │                     │
        │  - Description          │                     │
        │  - Parent (main task)   │                     │
        │  - Estimation (hours)   │                     │
        └──────────┬──────────────┘                     │
                   │                                     │
                   ▼                                     │
        ┌─────────────────────────┐                     │
        │  Assign Subtask to Me   │                     │
        │  (Auto-assign)          │                     │
        └──────────┬──────────────┘                     │
                   │                                     │
                   └─────────────────┐                   │
                                     │                   │
                (End Subtask Loop)   │                   │
                                     │                   │
                                     ▼                   │
                         ┌────────────────────────┐     │
                         │  Extract Feature Name  │     │
                         │                        │     │
                         │  From: Task Summary    │     │
                         │  Clean & Format:       │     │
                         │  "Add Login Page"      │     │
                         │  → "add-login-page"    │     │
                         └──────────┬─────────────┘     │
                                    │                    │
                                    ▼                    │
                      ┌──────────────────────────────┐  │
                      │  Create Bitbucket Branch     │  │
                      │                              │  │
                      │  Format:                     │  │
                      │  feature/[featurename]-PROJ-123 │
                      │                              │  │
                      │  Example:                    │  │
                      │  feature/add-login-page-PROJ-123 │
                      └──────────┬───────────────────┘  │
                                 │                       │
                                 ▼                       │
                         ┌──────────────┐               │
                         │  More Tasks? │               │
                         └──┬────────┬──┘               │
                            │        │                   │
                         YES│        │NO                 │
                            │        │                   │
                            └────────┤                   │
                                     │                   │
            (Loop back to process    │                   │
             next task) ──────────────┘                   │
                                     │                    │
                                     ▼                    │
                          ┌─────────────────────┐        │
                          │  Success Summary    │        │
                          │                     │        │
                          │  Output:            │        │
                          │  ✅ Tasks: 3        │        │
                          │  ✅ Subtasks: ~12   │        │
                          │  ✅ Branches: 3     │        │
                          │  ✅ AI: Rovo AI     │        │
                          └─────────────────────┘        │
                                     │                    │
                                     ▼                    │
                                  ┌─────┐                │
                                  │ END │                │
                                  └─────┘                │
                                                          │
═══════════════════════════════════════════════════════════
```

---

## 🔄 Error Handling & Fallback Logic

```
          ┌────────────────────────────────────────┐
          │         ROVO AI SERVICE                │
          └────────┬────────────────────────────┬──┘
                   │                            │
            SUCCESS│                            │FAIL/TIMEOUT
                   │                            │
                   ▼                            ▼
        ┌───────────────────┐      ┌──────────────────────┐
        │  Use AI Results   │      │   Automatic Fallback │
        │  (Smart breakdown)│      │   (Rule-based logic) │
        └───────────────────┘      └──────────────────────┘
                   │                            │
                   └────────────┬───────────────┘
                                │
                                ▼
                    ┌──────────────────────┐
                    │  Subtasks Created    │
                    │  (Guaranteed result) │
                    └──────────────────────┘
```

---

## 🎯 Data Flow Diagram

```
┌──────────────┐
│  INPUT:      │
│  Jira Tasks  │
│              │
│ • PROJ-123   │
│ • PROJ-124   │
│ • PROJ-125   │
└──────┬───────┘
       │
       ▼
┌───────────────────────────────────────────┐
│         PROCESSING PIPELINE               │
│                                           │
│  ┌─────────┐   ┌─────────┐   ┌────────┐ │
│  │ Task 1  ├──►│ Rovo AI ├──►│ Parse  │ │
│  └─────────┘   └─────────┘   └────┬───┘ │
│                                    │     │
│  ┌──────────────────────────────┐ │     │
│  │  Subtask 1: Setup API (4h)   │◄┘     │
│  │  Subtask 2: Add validation (2h)      │
│  │  Subtask 3: Write tests (3h)         │
│  │  Subtask 4: Documentation (1h)       │
│  └──────────────────────────────┘       │
│                                          │
└──────────────────┬───────────────────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  OUTPUT:            │
         │                     │
         │  Jira:              │
         │  ✅ 4 Subtasks      │
         │  ✅ Assigned to you │
         │  ✅ Time estimated  │
         │                     │
         │  Bitbucket:         │
         │  ✅ Branch created  │
         │  feature/setup-     │
         │  api-PROJ-123       │
         └─────────────────────┘
```

---

## 🔌 API Integration Map

```
┌─────────────────────────────────────────────────────────────┐
│                    n8n WORKFLOW ENGINE                      │
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌─────────────┐ │
│  │   Jira API   │    │  Rovo AI API │    │ Bitbucket   │ │
│  │              │    │              │    │     API     │ │
│  │ • Get tasks  │    │ • Analyze    │    │ • Create    │ │
│  │ • Create     │    │ • Breakdown  │    │   branch    │ │
│  │   subtasks   │    │ • Estimate   │    │ • From main │ │
│  │ • Assign     │    │              │    │             │ │
│  │ • Update     │    │              │    │             │ │
│  └──────┬───────┘    └──────┬───────┘    └──────┬──────┘ │
│         │                   │                    │        │
└─────────┼───────────────────┼────────────────────┼────────┘
          │                   │                    │
          ▼                   ▼                    ▼
┌─────────────────┐  ┌────────────────┐  ┌────────────────┐
│ Atlassian Cloud │  │  Rovo AI       │  │  Bitbucket     │
│                 │  │  (Intelligence)│  │  Cloud         │
│ yourcompany.    │  │                │  │                │
│ atlassian.net   │  │  Smart task    │  │  Repository    │
│                 │  │  analysis      │  │  management    │
└─────────────────┘  └────────────────┘  └────────────────┘
```

---

## 📝 Node-by-Node Breakdown

### 1️⃣ Manual Trigger
**Type:** Trigger
**Purpose:** Start workflow on-demand
**Output:** Empty execution trigger

### 2️⃣ Get My Assigned Tasks
**Type:** Jira API
**Action:** Query issues
**JQL:** `assignee = currentUser() AND parent is EMPTY AND resolution = Unresolved`
**Output:** Array of Jira tasks

### 3️⃣ Filter Parent Tasks Only
**Type:** IF condition
**Logic:** `subtasks.length == 0`
**Output:** Only tasks without existing subtasks

### 4️⃣ Loop Each Task
**Type:** Split In Batches
**Batch Size:** 1 (process sequentially)
**Output:** Single task item per iteration

### 5️⃣ Rovo AI: Break Down Task
**Type:** HTTP Request
**Method:** POST
**Endpoint:** `/rest/api/3/llm/analyze`
**Input:** Task summary + description
**Output:** JSON array of subtasks

### 6️⃣ AI Success?
**Type:** IF condition
**Logic:** Check for error field
**True:** Parse AI response
**False:** Use fallback

### 7️⃣ Parse AI Subtasks
**Type:** Code (JavaScript)
**Logic:** Extract JSON from AI response
**Output:** Structured subtask objects

### 8️⃣ Fallback: Rule-Based Breakdown
**Type:** Code (JavaScript)
**Logic:** Keyword matching (API, UI, bug, etc.)
**Output:** Predefined subtask templates

### 9️⃣ Rovo AI: Estimate Subtask
**Type:** HTTP Request
**Method:** POST
**Input:** Subtask title + complexity
**Output:** Estimated hours

### 🔟 Calculate Estimation
**Type:** Code (JavaScript)
**Logic:** Parse AI or use complexity map
**Output:** Hours + seconds for Jira

### 1️⃣1️⃣ Create Subtask in Jira
**Type:** Jira API
**Action:** Create issue (Sub-task type)
**Fields:** Title, description, parent, estimation
**Output:** Created subtask details

### 1️⃣2️⃣ Assign Subtask to Me
**Type:** Jira API
**Action:** Update issue assignee
**Output:** Updated subtask

### 1️⃣3️⃣ Extract Feature Name
**Type:** Code (JavaScript)
**Logic:** Clean summary → branch-friendly name
**Output:** Branch name string

### 1️⃣4️⃣ Create Bitbucket Branch
**Type:** HTTP Request
**Method:** POST
**Endpoint:** `/refs/branches`
**Input:** Branch name + base branch
**Output:** Branch details

### 1️⃣5️⃣ More Tasks?
**Type:** IF condition
**Logic:** Check loop has more items
**True:** Loop back
**False:** Continue to summary

### 1️⃣6️⃣ Success Summary
**Type:** Code (JavaScript)
**Logic:** Aggregate stats
**Output:** Execution summary

---

## ⏱️ Execution Timeline

```
Time (approx)     Node Activity
───────────────────────────────────────────────────────
0:00              Manual Trigger clicked
0:01              Fetching tasks from Jira...
0:03              Found 3 tasks, filtering...
0:04              Processing Task 1/3...
0:05              Calling Rovo AI...
0:07              AI returned 5 subtasks
0:08              Estimating subtask 1/5...
0:09              Creating subtask in Jira...
0:10              Assigning subtask...
0:11              Repeat for subtasks 2-5...
0:25              All subtasks created
0:26              Extracting feature name...
0:27              Creating Bitbucket branch...
0:28              Task 1 complete!
0:29              Processing Task 2/3...
...
1:30              All tasks processed
1:31              Generating summary...
1:32              ✅ Complete!
```

**Average time per task:** ~30-45 seconds
**Total for 3 tasks:** ~1.5-2 minutes

---

## 🎨 Visual Summary

```
┌─────────────────────────────────────────────────────────┐
│                  AUTOMATION BENEFITS                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Manual Process (Before):                              │
│  ├─ Read task description           (5 min)           │
│  ├─ Think about breakdown           (10 min)          │
│  ├─ Create subtasks manually        (15 min)          │
│  ├─ Assign each one                 (5 min)           │
│  ├─ Estimate time                   (5 min)           │
│  └─ Create branch                   (2 min)           │
│      Total: ~42 minutes per task                      │
│                                                         │
│  ────────────────────────────────────────────────────  │
│                                                         │
│  Automated Process (After):                            │
│  ├─ Click "Execute Workflow"        (1 sec)           │
│  └─ Wait for completion             (45 sec)          │
│      Total: ~46 seconds per task                      │
│                                                         │
│  ⚡ TIME SAVED: ~41 minutes per task                   │
│  ⚡ EFFORT REDUCTION: ~98%                             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

**This flow diagram shows the complete automation pipeline from trigger to completion!** 🎉
