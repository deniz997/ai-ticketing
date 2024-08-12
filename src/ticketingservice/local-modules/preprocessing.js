module.exports.preprocess = function (trace){
    const stringTrace = JSON.stringify(trace);
    console.log(stringTrace)
    const trimmedTrace = stringTrace.trim();
    return trimmedTrace;
}