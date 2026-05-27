## Summary

- 

## Package Or Area

- [ ] `pharmax.viz`
- [ ] `pharmax.ml`
- [ ] site/docs
- [ ] CI/release

## Safety Check

- [ ] Uses public or synthetic data only
- [ ] Does not include `.env`, credentials, clinical data, or proprietary files
- [ ] Avoids unsupported regulatory/commercial claims

## Verification

```bash
bash tools/public-release-check.sh "$PWD"
```

```bash
# If package code changed, run the relevant package check.
cd packages/pharmax.viz
R -q -e 'devtools::test(); devtools::check(error_on = "never")'
```

## Notes

- 
