import subprocess
import tkinter as tk
from tkinter import filedialog

def leer_datos_desde_archivo(ruta_archivo):
    nombres_variables = [
        "K", "J", "Ej", "Aj", "Gj", "Fj", "Vj", "Pj_lower", "Pj_upper",
        "Supj", "Infj", "P0j", "Dk", "Rk"
    ]
    with open(ruta_archivo, 'r') as archivo:
        lineas = archivo.readlines()  
        datos = []
        for linea in lineas:
            valores = [val.strip('[]') for val in linea.strip().split(',')]
            datos.append(valores)

    with open('datos.dzn', 'w') as archivo_dzn:
        for i, (nombre, valores) in enumerate(zip(nombres_variables, datos)):
            decimales = [val for val in valores if '.' in val]
            enteros = [val for val in valores if '.' not in val]

            if decimales or enteros:
                archivo_dzn.write(f'{nombre} = ')
                if i < 2:
                    if enteros:
                        archivo_dzn.write(f'{", ".join(enteros)};\n')
                else:
                    archivo_dzn.write(f'[{", ".join(decimales + enteros)}];\n')

def ejecutarMzn():
    comando = f'minizinc --solver gecode "Proyecto ada.mzn" "datos.dzn"'
    proceso = subprocess.Popen(comando, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    salida, errores = proceso.communicate()
    if errores:
        print(f"Se han producido errores: {errores.decode('utf-8')}")
    with open('salida.txt', 'wb') as salida_archivo:
        salida_archivo.write(salida)

def seleccionar_archivo():
    archivo_seleccionado = filedialog.askopenfilename(filetypes=[("Archivos de texto", "*.txt")])
    if archivo_seleccionado:
        leer_datos_desde_archivo(archivo_seleccionado)
        ejecutarMzn()
        mostrar_resultados()

def mostrar_resultados():
    with open('salida.txt', 'r') as archivo_resultados:
        resultados = archivo_resultados.read()
        text_area.delete(1.0, tk.END)  # Limpiar el Text widget
        text_area.insert(tk.END, resultados)

def main():
    global text_area
    ventana = tk.Tk()
    ventana.title("Interfaz para ejecutar Minizinc")

    boton_seleccionar_archivo = tk.Button(ventana, text="Seleccionar Archivo", command=seleccionar_archivo)
    boton_seleccionar_archivo.pack()

    text_area = tk.Text(ventana, height=20, width=60)
    text_area.pack()

    ventana.mainloop()

if __name__ == "__main__":
    main()