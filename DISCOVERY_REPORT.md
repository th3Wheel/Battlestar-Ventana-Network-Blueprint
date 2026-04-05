# API Discovery Report

Generated: 2026-03-04T09:00:53.460Z

Total API specs: 0
Total endpoints: 0

## Endpoints by Framework

## Files

## Gaps / Notes

- No endpoints discovered.
- FastAPI not detected (if expected, ensure decorators @app.get etc. are present)
- Gin not detected (look for gin.Default() or router groups)
- ASP.NET Core not detected (ensure WebApplication.CreateBuilder or [ApiController])
- Spring Boot not detected (ensure @RestController / @GetMapping etc.)

## Next Potential Enhancements

- Runtime probing for live OpenAPI (start server & fetch swagger/openapi).
- Parameter & schema inference via AST/type inspection.
- Multi-file router aggregation for FastAPI and Gin nested groups.
- Caching & change detection to avoid full rescans.
- Security scheme extraction (auth middleware heuristics).
