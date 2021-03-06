# ----------------------------------------------------------------------------
# http://www.dicio.com.br
# Dicionário de português.
# Definição de palavras e conjugação verbal
# Fornecendo uma "palavra" como argumento retorna seu significado e sinônimo.
# Se for seguida do termo "def", retorna suas definições.
# Se for seguida do termo "conj", retorna todas as formas de conjugação.
# Pode-se filtrar pelos modos de conjugação, fornecendo após o "conj" o modo
# desejado:
# ind (indicativo), sub (subjuntivo), imp (imperativo), inf (infinitivo)
#
# Uso: zzdicportugues2 palavra [def|conj [ind|sub|conj|imp|inf]]
# Ex.: zzdicportugues2 bolacha
#      zzdicportugues2 verbo conj sub
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-04-16
# Versão: 5
# Licença: GPL
# Requisitos: zzsemacento zzminusculas
# ----------------------------------------------------------------------------
zzdicportugues2 ()
{
	zzzz -h dicportugues2 "$1" && return

	local url='http://dicio.com.br'
	local ini='^significado de '
	local fim='^defini..o de '
	local palavra=$(echo "$1" | zzminusculas)
	local padrao=$(echo "$palavra" | zzsemacento)
	local contador=1
	local resultado

	# Verificação dos parâmetros
	[ "$1" ] || { zztool uso dicportugues2; return 1; }

	# Verificando se a palavra confere na pesquisa
	until [ "$resultado" = "$palavra" ]
	do
		resultado=$(
		$ZZWWWDUMP "$url/$padrao" |
			sed -n "
			/^Significado de /{
				s/^Significado de //
				s/ *$//
				p
				}" |
			zzminusculas
			)
		[ "$resultado" ] || { zztool eco "Palavra não encontrada"; return 1; }

		# Incrementando o contador no padrão
		padrao=$(echo "$padrao" | sed 's/_[0-9]*$//')
		contador=$((contador + 1))
		padrao=${padrao}_${contador}
	done

	# Restabelecendo o contador
	padrao=$(echo "$padrao" | sed 's/_[0-9]*$//')
	contador=$((contador - 1))
	padrao=$(echo "${padrao}_${contador}" | sed 's/_1$//')

	case "$2" in
	def) ini='^defini..o de '; fim=' escrit. ao contr.rio: ' ;;
	conj)
		ini='^ *infinitivo:'; fim='(rimas com |anagramas de )'
		case "$3" in
			ind) ini='^ *indicativo'; fim='^ *subjuntivo' ;;
			sub | conj) ini='^ *subjuntivo'; fim='^ *imperativo' ;;
			imp) ini='^ *imperativo'; fim='^ *infinitivo' ;;
			inf) ini='^ *infinitivo *$' ;;
		esac
	;;
	esac

	case "$2" in
	conj)
		$ZZWWWDUMP "$url/$padrao" |
		awk 'tolower($0) ~ /'"$ini"'/, tolower($0) ~ /'"$fim"'/ {print} ' |
			sed "
				{
				/^ *INDICATIVO *$/d
				/^ *Indicativo *$/d
				/^ *SUBJUNTIVO *$/d
				/^ *Subjuntivo *$/d
				#/^ *CONJUNTIVO *$/d
				#/^ *Conjuntivo *$/d
				/^ *IMPERATIVO *$/d
				/^ *Imperativo *$/d
				/^ *INFINITIVO *$/d
				/^ *Infinitivo *$/d
				/Rimas com /d
				/Anagramas de /d
				/^ *$/d
				s/^ *//
				s/^\*/\n&/
				#s/ do Indicativo/&\n/
				#s/ do Subjuntivo/&\n/
				#s/ do Conjuntivo/&\n/
				#s/\* Imperativo Afirmativo/&\n/
				#s/\* Imperativo Negativo/&\n/
				#s/\* Imperativo/&\n/
				#s/\* Infinitivo Pessoal/&\n/
				s/^[a-z]/ &/g
				#p
				}"
	;;
	*)
		$ZZWWWDUMP "$url/$padrao" |
		awk 'tolower($0) ~ /'"$ini"'/, tolower($0) ~ /'"$fim"'/ {print} ' |
			sed "1d;/^Definição de /d;" #/Infinitivo:/,/Particípio passado:/p"
	;;
	esac
}
