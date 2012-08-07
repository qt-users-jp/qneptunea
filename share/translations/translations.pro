# var, prepend, append
defineReplace(prependAll) {
	for(a,$$1):result += $$2$${a}$$3
	return($$result)
}

LANGUAGES = en ja tr fi

TEMPLATE = app
TARGET = phony_target
CONFIG -= qt
QT =
LIBS =

isEmpty(vcproj) {
	QMAKE_LINK = @: IGNORE THIS LINE
	OBJECTS_DIR =
	win32:CONFIG -= embed_manifest_exe
} else {
	CONFIG += console
	PHONY_DEPS = .
	phony_src.input = PHONY_DEPS
	phony_src.output = phony.c
	phony_src.variable_out = GENERATED_SOURCES
	phony_src.commands = echo int main() { return 0; } > phony.c
	phony_src.name = CREATE phony.c
	phony_src.CONFIG += combine
	QMAKE_EXTRA_COMPILERS += phony_src
}

LUPDATE = $$[QT_INSTALL_BINS]/lupdate -locations relative -no-ui-lines
LRELEASE = $$[QT_INSTALL_BINS]/lrelease

TRANSLATIONS = $$prependAll(LANGUAGES, $$PWD/qneptunea_,.ts)

lupdate.files = TRANSLATIONS
lupdate.commands = $$LUPDATE $$PWD/../../ -ts $$TRANSLATIONS

QMAKE_EXTRA_TARGETS += lupdate

qm.depends = lupdate
qm.input = TRANSLATIONS
qm.output = $$OUT_PWD/${QMAKE_FILE_BASE}.qm
qm.commands = $$LRELEASE ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_OUT}
qm.name = LRELEASE ${QMAKE_FILE_IN}
qm.CONFIG += no_link
QMAKE_EXTRA_COMPILERS += qm
PRE_TARGETDEPS += compiler_qm_make_all

qmfiles.files = $$prependAll(LANGUAGES, $$OUT_PWD/qneptunea_,.qm)
qmfiles.path = /opt/qneptunea/share/translations
qmfiles.CONFIG = no_check_exist
INSTALLS += qmfiles

OTHER_FILES += \
    Translation.qml
