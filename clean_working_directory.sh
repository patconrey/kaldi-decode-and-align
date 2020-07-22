unlink conf && unlink local && unlink steps && unlink utils
rm -rf data
rm -rf exp
rm -rf experiment_results
if [ -e "./mfcc/" ]; then
    rm -rf mfcc
fi