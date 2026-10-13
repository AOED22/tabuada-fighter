extends Control

signal confirmado(valor: int)

@export var cor_destaque: Color = Color(0.3, 0.64, 1.0)
@export var max_digitos: int = 3

var colunas: int = 3
var cursor: int = 4
var texto: String = ""
var travada: bool = false

var _estilo_normal: StyleBox
var _estilo_selecionado: StyleBoxFlat

@onready var visor_texto: Label = $Visor/Texto
@onready var teclas: Array = $Teclas.get_children()


func _ready() -> void:
	_estilo_normal = teclas[0].get_theme_stylebox("normal")
	_estilo_selecionado = _estilo_normal.duplicate() as StyleBoxFlat
	_estilo_selecionado.bg_color = cor_destaque.darkened(0.25)
	_estilo_selecionado.border_color = cor_destaque.lightened(0.3)
	_estilo_selecionado.set_border_width_all(3)
	_atualizar()


@warning_ignore("integer_division")
func mover(direcao: Vector2i) -> void:
	if travada:
		return
	var linhas: int = teclas.size() / colunas
	var coluna: int = wrapi(cursor % colunas + direcao.x, 0, colunas)
	var linha: int = wrapi(cursor / colunas + direcao.y, 0, linhas)
	cursor = linha * colunas + coluna
	_atualizar()


func apertar() -> void:
	if travada:
		return
	var tecla: String = teclas[cursor].text
	match tecla:
		"DEL":
			texto = texto.substr(0, texto.length() - 1)
		"OK":
			if texto != "":
				confirmado.emit(int(texto))
		_:
			if texto.length() < max_digitos:
				texto += tecla
	_atualizar()


func limpar() -> void:
	texto = ""
	_atualizar()


func errou() -> void:
	limpar()
	$AnimationPlayer.play("errou")


func _atualizar() -> void:
	visor_texto.text = texto
	for i in teclas.size():
		var estilo: StyleBox = _estilo_selecionado if i == cursor else _estilo_normal
		teclas[i].add_theme_stylebox_override("normal", estilo)
