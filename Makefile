
MODULES="str netclient netstring"
NAME=get_french_audio

all:
	 ocamlfind opt -package ${MODULES} -linkpkg -thread ${NAME}.ml -o ${NAME}

clean:
	rm -f ${NAME}{,.cmi,.cmx,.o}