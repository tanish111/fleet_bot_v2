# GEMINI Instructions for Individual Bot in Large Fleet of Autonomous Agents  

This document outlines the protocol for GEMINI to operate as an individual bot in a large fleet of autonomous agents. Follow the structured steps below to ensure proper execution of tasks and seamless integration with the fleet.  

---

## Protocol  

### 1. **Determine Mode Based on Prompt**  
    - If the prompt starts with **Implementation MODE**, follow the existing protocol steps below.  
    - If the prompt starts with **Creation MODE**, generate new instructions based on the details provided in the prompt.  

---

### Implementation MODE  

#### 1. **Check Git Log for Dependencies**  
    - Use `git log` to review commit history.  
    - Verify if all dependent instructions related to the assigned task are completed.  
    - Ensure commit messages contain the commit-id for dependent instructions.  

#### 2. **Work on Assigned Task**  
    - If all dependencies are completed, proceed with the assigned task.  
    - Focus only on the task assigned to you.  

#### 3. **Create Feature Branch**  
    - Use the nomenclature: `commit-id:hostname`.  
    - Commit changes with the following format:  
      - **Title:** `commit-id:hostname-<Title of commit>`  
      - **Message:** Include details of what was done.  

#### 4. **Push Changes to Feature Branch**  
    - Push the changes to the newly created feature branch.  

#### 5. **Create Pull Request (PR)**  
    - Use GitHub MCP tools to create a PR to merge the feature branch with the `main` branch.  
    - Ensure the PR is mergeable with no conflicts.  

#### 6. **Merge PR**  
    - Once the PR is created and verified as mergeable, merge it with the `main` branch.  
    - Switch to the `main` branch after merging.  

#### 7. **Update Memory**  
    - Use the memory tool to record what was done with the commit-id for future reference.  

#### 8. **Task Completion**  
    - Once the PR is merged and memory updated, the task is considered complete.  

---

### Creation MODE  

#### 1. **Generate New Instructions**  
    - Analyze the details provided in the prompt.  
    - Create a structured protocol tailored to the requirements specified.  
    - Ensure the instructions are clear, concise, and actionable.  

#### 2. **Validate Instructions**  
    - Review the generated instructions for accuracy and completeness.  
    - Ensure the instructions align with the fleet's operational standards.  

#### 3. **Distribute Instructions**  
    - Share the new instructions with relevant team members or bots.  
    - Ensure proper understanding and implementation of the instructions.  

---

## Notes  
- Follow the protocol sequentially to avoid errors.  
- Ensure all dependencies are verified before starting the assigned task.  
- Maintain clear and concise commit messages for traceability.  
- Always determine the mode based on the prompt before proceeding.  

---  
**End of Instructions**  