% === ARCHIVOS Y TÍTULOS POR SITUACIÓN ===
archivos = {'C:\Users\abram\OneDrive\Escritorio\Trabajos UNI\UNI6\caminando1convertidos.txt', ...
            'C:\Users\abram\OneDrive\Escritorio\Trabajos UNI\UNI6\caminando2convertidos.txt', ...
            'C:\Users\abram\OneDrive\Escritorio\Trabajos UNI\UNI6\caminando3convertidos.txt'};

titulos = {'caminando', 'caminando2', 'caminando3'};

% === RECORRER CADA ARCHIVO (SITUACIÓN) ===
for i = 1:length(archivos)
    archivo = archivos{i};
    titulo_evento = titulos{i};

    % === Verificar existencia del archivo
    if ~isfile(archivo)
        warning('No se encontró el archivo: %s. Se omite.', archivo);
        continue;
    end

    % === Leer archivo con delimitador de tabulación ===
    opts = detectImportOptions(archivo, 'Delimiter', '\t');
    opts.VariableNamesLine = 1;
    opts = setvartype(opts, {'Time'}, 'string');  % Leer tiempo como string
    datos = readtable(archivo, opts);

    % === Arreglar nombres de columnas por si tienen caracteres inválidos ===
    datos.Properties.VariableNames = matlab.lang.makeValidName(datos.Properties.VariableNames);

    % === Convertir tiempo a formato datetime si existe ===
    if any(strcmp('Time', datos.Properties.VariableNames))
        try
            datos.Time = datetime(datos.Time, 'InputFormat', 'HH:mm:ss.SSS', 'Format', 'HH:mm:ss.SSS');
        catch
            datos.Time = (1:height(datos))'; % fallback por si falla
        end
    else
        datos.Time = (1:height(datos))';
    end

    % === IDs únicos en el archivo ===
    ids_unicos = unique(datos.ID);

    % === Crear figura única para esta actividad ===
    figure('Name', titulo_evento, 'NumberTitle', 'off');
    sgtitle(sprintf('Aceleraciones - %s', titulo_evento), 'FontSize', 14, 'FontWeight', 'bold');

    for j = 1:length(ids_unicos)
        id_actual = ids_unicos(j);
        datos_id = datos(datos.ID == id_actual, :);

        subplot(3, 2, j);  % 3 filas, 2 columnas
        plot(datos_id.Time, datos_id.Ax_cm_s2, 'r', 'DisplayName', 'Ax');
        hold on;
        plot(datos_id.Time, datos_id.Ay_cm_s2, 'g', 'DisplayName', 'Ay');
        plot(datos_id.Time, datos_id.Az_cm_s2, 'b', 'DisplayName', 'Az');
        hold off;

        title(sprintf('ID %d', id_actual));
        xlabel('Tiempo');
        ylabel('Aceleración (cm/s²)');
        legend;
        grid on;
    end
end
