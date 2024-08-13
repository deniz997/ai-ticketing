const getErrorSpanEndTime = (traceData) => {
    let minEndUnixTime = undefined;
    traceData.resourceSpans.forEach((resourceSpan) => {
        resourceSpan.scopeSpans.forEach((scopeSpan) => {
            scopeSpan.spans.forEach((span) => {
                if (minEndUnixTime === undefined || span.endTimeUnixNano < minEndUnixTime) {
                    minEndUnixTime = span.endTimeUnixNano
                }
            })
        });
    });
    return minEndUnixTime;
}
