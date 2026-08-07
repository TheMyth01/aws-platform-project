# Cost Allocation Tag Activation and Backfill Evidence

**Date:** 2026-08-07  
**AWS service:** Cost Explorer / Cost Allocation Tags  
**Status:** IMPLEMENTED

## Tags activated

The five project cost allocation tags were verified through the AWS CLI as existing UserDefined tags and initially Inactive:

- Project
- Environment
- Owner
- CostCenter
- ManagedBy

Activation command:

```powershell
aws ce update-cost-allocation-tags-status --cost-allocation-tags-status TagKey=Project,Status=Active TagKey=Environment,Status=Active TagKey=Owner,Status=Active TagKey=CostCenter,Status=Active TagKey=ManagedBy,Status=Active
```

AWS returned:

```json
{
  "Errors": []
}
```

A subsequent verification query confirmed all five tags were Active:

```powershell
aws ce list-cost-allocation-tags --tag-keys Project Environment Owner CostCenter ManagedBy --query "CostAllocationTags[*].[TagKey,Status,Type,LastUsedDate]" --output table
```

Verified status:

| Tag key | Status | Type |
|---|---|---|
| ManagedBy | Active | UserDefined |
| Environment | Active | UserDefined |
| Project | Active | UserDefined |
| CostCenter | Active | UserDefined |
| Owner | Active | UserDefined |

## Historical backfill request

A cost allocation tag backfill was requested from 1 April 2026:

```powershell
aws ce start-cost-allocation-tag-backfill --backfill-from 2026-04-01T00:00:00Z
```

AWS accepted the request with:

```json
{
  "BackfillRequest": {
    "BackfillFrom": "2026-04-01T00:00:00Z",
    "RequestedAt": "2026-08-07T15:05:58Z",
    "BackfillStatus": "PROCESSING",
    "LastUpdatedAt": "2026-08-07T15:05:58Z"
  }
}
```

## Interpretation

The project can now truthfully state that the five cost allocation tag keys have been activated in AWS Billing/Cost Explorer. The April 2026 historical backfill is still processing and must not be described as complete until AWS reports a completed status and historical tag values are verified.

The backfill can only recover historical tag allocation where the AWS resource actually carried the relevant tag at the time. The managed EKS node-group propagation gap remains a known limitation to fix before the next instrumented deployment.
