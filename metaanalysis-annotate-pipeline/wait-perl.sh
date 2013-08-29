PROCESS_NAME="perl"
PROCESS_LIMIT="20"
PROCESS_COUNT="-1"
SLEEP_TIME="5"
DEBUG="0"
sleep 1

while [ "${PROCESS_COUNT}" -eq "-1" -o "${PROCESS_COUNT}" -ge "${PROCESS_LIMIT}" ]
do
	PROCESS_COUNT=`ps x | grep ${PROCESS_NAME} | grep -v grep | wc -l`
	if [ "${DEBUG}" -eq "1" ]
	then
		echo "Current Process Count: ${PROCESS_COUNT}"
	fi

	if [ ${PROCESS_COUNT} -ge ${PROCESS_LIMIT} ]
	then
		if [ "${DEBUG}" -eq "1" ]
		then
			echo "Sleeping ${SLEEP_TIME} seconds"
		fi
		sleep 5
	fi
done

if [ "${DEBUG}" -eq "1" ]
then
	echo "Continue execution; Process Count = ${PROCESS_COUNT}"
fi
