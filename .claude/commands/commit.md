## Commit Strategy

- IMPORTANT: No secret files, secrets, api keys should be committed, don't add files if they contain secrets and are not part of .gitignore as well
- Feature-based commits only: Commit when a complete, self-contained feature is ready, not for individual file changes
- One feature per commit: Each commit should represent a single, cohesive feature or functionality
- Functional state: Every commit must leave the codebase in a working, testable state

## Commit Message Format

```
feat: [Brief feature description]

## Feature Description
[Detailed explanation of what the feature does and why it was needed]

## Prompt History
[Include the key prompts/conversations that led to this implementation]
```

Write the message to the text file for the commit. Don't commit the changes.

Also, don't add
Co-Authored-By: Claude <noreply@anthropic.com>"
Create commit with detailed message about age range standardization