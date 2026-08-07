# Cost allocation tag activation and historical backfill evidence

**Status:** IMPLEMENTED / VERIFIED

**Date:** 7 August 2026

## Activated cost allocation tags

The following user-defined cost allocation tags were verified through the AWS CLI and then activated:

- `Project`
- `Environment`
- `Owner`
- `CostCenter`
- `ManagedBy`

Verification after activation returned all five with `Status = Active`.

## Historical backfill request

AWS CLI command:

```powershell
aws ce start-cost-allocation-tag-backfill --backfill-from 2026-04-01T00:00:00Z
```

Initial response:

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

Follow-up verification:

```powershell
aws ce list-cost-allocation-tag-backfill-history
```

Returned:

```json
{
  "BackfillRequests": [
    {
      "BackfillFrom": "2026-04-01T00:00:00Z",
      "RequestedAt": "2026-08-07T15:05:58Z",
      "CompletedAt": "2026-08-07T15:11:44Z",
      "BackfillStatus": "SUCCEEDED",
      "LastUpdatedAt": "2026-08-07T15:11:44Z"
    }
  ]
}
```

## Interpretation

The AWS cost allocation tag backfill request completed successfully for the period beginning 1 April 2026. This does not guarantee that every historical line item will contain all five tag values; historical allocation is only available where the underlying resources carried those tags at the time. The result must therefore be validated in Cost Explorer and CUR 2.0 once refreshed data is available.
