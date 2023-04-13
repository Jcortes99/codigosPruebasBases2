package views;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.internal.LinkedTreeMap;
import multichain.command.CommandManager;
import multichain.command.CommandElt;
import multichain.command.MultichainException;
import multichain.object.StreamKeyItem;

import java.util.Base64;
import java.util.List;

import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import java.awt.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

public class SubirCertificado extends JFrame {

    public static CommandManager commandManager;

    private static JPanel contentPanel;
    private static JButton btnSubir;
    private static JLabel lblTitulo;
    private static JLabel lblCodigo;
    private static JTextField txtPasaporte;
    private static JTextField txtCodigo;
    private static JLabel lblPasaporte;
    private static JButton btnFile;
    private static JLabel lblDiploma;
    private static JLabel lblNamefile;
    private static JLabel lblFecha;
    private static JTextField txtFecha;

    private static String encodingfile;

    public SubirCertificado(CommandManager _commandManager) {
        super("Subir certificado");
        this.commandManager = _commandManager;
        initComponents();
    }

    private void initComponents() {
        //construct components
        contentPanel = new JPanel();
        btnSubir = new JButton ("Subir");
        lblTitulo = new JLabel ("Subir certificado");
        lblCodigo = new JLabel ("Código del programa: ");
        txtPasaporte = new JTextField (40);
        txtCodigo = new JTextField (40);
        lblPasaporte = new JLabel ("Pasaporte:");
        lblDiploma = new JLabel ("Diploma:");
        btnFile = new JButton ("Choose a file");
        lblNamefile = new JLabel ("");
        lblFecha = new JLabel ("Fecha de expedición: ");
        txtFecha = new JTextField (20);


        lblTitulo.setFont(new java.awt.Font("Segoe UI", 0, 18));
        //adjust size and set layout
        contentPanel.setPreferredSize (new Dimension(526, 243));
        contentPanel.setLayout (null);

        //add components
        contentPanel.add (btnSubir);
        contentPanel.add (lblTitulo);
        contentPanel.add (lblCodigo);
        contentPanel.add (txtPasaporte);
        contentPanel.add (txtCodigo);
        contentPanel.add (lblPasaporte);
        contentPanel.add (lblDiploma);
        contentPanel.add (btnFile);
        contentPanel.add (lblNamefile);
        contentPanel.add (lblFecha);
        contentPanel.add (txtFecha);

        //set component bounds (only needed by Absolute Positioning)
        btnSubir.setBounds (175, 195, 155, 25);
        lblTitulo.setBounds (195, 10, 250, 35);
        lblCodigo.setBounds (265, 55, 145, 25);
        txtPasaporte.setBounds (50, 90, 190, 25);
        txtCodigo.setBounds (265, 90, 190, 25);
        lblPasaporte.setBounds (50, 55, 100, 25);
        lblDiploma.setBounds (265, 120, 55, 25);
        btnFile.setBounds (265, 145, 190, 25);
        lblNamefile.setBounds (265, 170, 250, 25);
        lblFecha.setBounds (50, 120, 145, 25);
        txtFecha.setBounds (50, 145, 190, 25);

        //actionListener for FileChooser
        btnFile.addActionListener(evt -> {
            JFileChooser fileChooser = new JFileChooser();

            try {
                //Filter para el archivo
                FileNameExtensionFilter filter = new FileNameExtensionFilter("PDFs","pdf");
                fileChooser.setFileFilter(filter);
                fileChooser.showOpenDialog(null);
                File file = fileChooser.getSelectedFile();
                String filename = file.getName();
                lblNamefile.setText(filename);

                byte[] fileContent = Files.readAllBytes(file.toPath());
                String encodefile = Base64.getEncoder().encodeToString(fileContent);
                this.encodingfile = encodefile;
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        });

        //actionListener for the botton Subir
        btnSubir.addActionListener(evt -> {
            String pasaporte = txtPasaporte.getText();
            String codigo = txtCodigo.getText();
            String fecha = txtFecha.getText();
            List<StreamKeyItem> items;

            try {
                // Validaciones
                if ((pasaporte.equals("") && codigo.equals("")) || fecha.equals("")) {
                    throw new Exception("Hay campos sin llenar");
                }
                if (lblNamefile.getText().equals("")) {
                    throw new Exception("No ha seleccionado ningún archivo");
                }

                String stream = "Graduandos";
                commandManager.invoke(CommandElt.SUBSCRIBE, stream);
                items = (List<StreamKeyItem>) commandManager.invoke(CommandElt.LISTSTREAMKEYITEMS, stream, pasaporte);
                if (items.isEmpty()) {
                    throw new Exception("Pasaporte no existe en Stream Graduandos");
                }

                // Inserción
                String[] key = {pasaporte, codigo};

                LinkedTreeMap JSONin = new LinkedTreeMap();
                JSONin.put("fecha_expedicion", fecha);
                JSONin.put("diploma", this.encodingfile);

                LinkedTreeMap JSONout = new LinkedTreeMap();
                JSONout.put("json", JSONin);

                Gson gson = new Gson();
                JsonObject JSONFULL = gson.toJsonTree(JSONout).getAsJsonObject();
                System.out.println(JSONFULL);

                Object Hash;
                commandManager.invoke(CommandElt.SETRUNTIMEPARAM, "maxshowndata", 131072);
                Hash =  commandManager.invoke(CommandElt.PUBLISH, "Certificados", key, JSONFULL);
                JOptionPane.showMessageDialog(null, "Registrado correctamente \n Id de la transacción: "+ Hash.toString());

                txtPasaporte.setText("");
                txtCodigo.setText("");
                txtFecha.setText("");
                lblNamefile.setText("");

            } catch (MultichainException e) {
                e.printStackTrace();
                throw new RuntimeException(e);
            } catch (Exception e) {
                JOptionPane.showMessageDialog(null, e.getMessage());
            }
        });
    }

    public void loadForm(){
        setContentPane(contentPanel);
        setDefaultCloseOperation(JFrame.HIDE_ON_CLOSE);
        pack();
        setLocationRelativeTo(null);
        setVisible(true);
        setResizable(false);
    }
}
