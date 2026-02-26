# Ticket Triage Output Examples

## Remediated Example Format

Show a before/after for the most impactful section of the ticket. This teaches the team the pattern so they can apply it to other tickets.

> **Before:**
> - User can create a task
> - Tasks persist in the database
>
> **After:**
> - When a user fills in the task title and clicks "Create", they are redirected to the task list and the new task appears at the top
> - When a user creates a task without a title, a validation error "Title is required" appears below the title field
> - When a user refreshes the task list page, all previously created tasks are still visible
