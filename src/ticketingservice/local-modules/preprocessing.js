module.exports.preprocess = function (trace){
    const stringTrace = JSON.stringify(trace);
    const trimmedTrace = stringTrace.trim();
    return trimmedTrace;
}