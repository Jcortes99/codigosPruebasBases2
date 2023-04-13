// SPDX-License-Identifier: GPL-3.0
// versión de solidity
pragma solidity >=0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";
//Dudas: ¿los codigos de propuesta deben ser unicos?

contract Punto2 {
    //Declaracion de variables
    address payable public presidente; //El address del que creo el contrato
    enum State { Created, Ended }
    State public state;

    //Se crea el modificador para controlar que el presidente no vote.
    modifier noEsPresidente(){
        require(msg.sender != presidente, "El presidente no puede votar en su contrato");
        _;
    }
    modifier esPresidente(){
        require(msg.sender == presidente, "Solo el presidente puede realizar esta opcion");
        _;
    }

    modifier esAdmin(uint _codigoPropuesta){
        uint a = 0;
        for (uint i=0;i<beneficiarios[_codigoPropuesta].length;i++){
            if (msg.sender == beneficiarios[_codigoPropuesta][i]){
                a = 1;
            }
        }
        require(msg.sender == presidente || a == 1, "Solo el presidente y los beneficiarios pueden realizar esta opcion");
        _;
    }

    modifier inState(State _state, uint _codigoPropuesta){
        state = estadoPropuesta[_codigoPropuesta];
        require(state == _state);
        _;
    }

    //Estructuras:
    //Se crea la estructura propuesta
    struct propuesta{
        uint codigoPropuesta;
        string textoPropuesta;
        uint cantidadOpciones;
        uint costoVoto;
        uint tiempoVoto;
    }
    propuesta[] public propuestas; //Se crea el arreglo de la estructura propuesta

    //Se crea la estructura para el voto
    struct voto{
        uint codigoPropuesta;
        uint opcionPropuesta;
    }
    

    struct votante{
        address payable codigoVotante;
    }
    votante[] public votantes;
    //Fin estructuras.

    //Eventos:

    //event votoGuardado(address vote, )


    //Fin eventos.

    //Mappings
    mapping (address => mapping (uint=>uint)) public totalvotos;
    mapping (uint => address payable []) public beneficiarios;
    mapping (uint => mapping (uint => uint)) public dineroopcion;
    mapping (uint => State) public estadoPropuesta;
    mapping (uint => uint) public tiempoRestante;
    mapping (uint => uint) public aumentoTiempo;
    mapping (uint => uint) public reduccionTiempo;
    mapping (uint => uint) public dineroCambio;
    //Fin Mappings.

    constructor(){
        presidente = payable(msg.sender); //Establece el presidente del contrato
    }

    function aucEnd(uint _codigoPropuesta) public returns(bool){
        require(block.timestamp >= tiempoRestante[_codigoPropuesta], "Aun hay tiempo");
        estadoPropuesta[_codigoPropuesta] = State.Ended;
        return true;
    }

    function CrearPropuesta(uint _codigoPropuesta,string memory textoPropuesta,uint cantidadOpciones,uint costoVoto,uint tiempoVoto) public esPresidente returns(string memory aux){

        //Controlar la cantidad de opciones (cantidadOpciones), 2 <= cantidadOpciones <= 10
        if(cantidadOpciones < 2){
            return "Error, cantidad de Opciones es menor a dos";
        }
        if(cantidadOpciones > 10){
            return "Error, cantidad de Opciones es mayor a diez";
        }

        //Controlar el costo de votar (costoVoto), 1 <= costoVoto <= 5
        if(costoVoto < 1){
            return "Error, el costo de voto es menor a 1 Etherium";
        }
        if(costoVoto > 5){
            return "Error, el costo de voto es mayor a 5 Etherium";
        }

        //Controlar el timepo de votacion (tiempoVoto), tiempoVoto > 120
        if(tiempoVoto < 120){
            return "Error, el tiempo de voto es menor a 120 segundos";
        }

        //Controlar la cantidad de propuestas, 1 <= longitud de propuestas[] <= 3
        if(propuestas.length > 3){
           return "Error, se alcanzo el limite de 3 propuestas";
        }
        uint cont = 0;
        for (uint i=0; i<propuestas.length;i++){
            if(propuestas[i].codigoPropuesta == _codigoPropuesta){
                cont ++;
            }
        }
        if (cont != 0){
            return "Error, la propuesta ya existe";
        }
        propuestas.push(propuesta(_codigoPropuesta, textoPropuesta, cantidadOpciones, costoVoto, tiempoVoto));
        estadoPropuesta[_codigoPropuesta] = State.Created;
        tiempoRestante[_codigoPropuesta] = block.timestamp + tiempoVoto;
        return "propuesta Guardada";
    }

    function Votar (uint _codigoPropuesta, uint _opcionPropuesta) public noEsPresidente inState(State.Created, _codigoPropuesta) returns(string memory){
        //verificar quien es el que votacion
        uint cont = 0;
        uint costo;
        uint precio;
        for (uint i=0; i<propuestas.length;i++){
            if(propuestas[i].codigoPropuesta == _codigoPropuesta){
                if(propuestas[i].cantidadOpciones >= _opcionPropuesta && _opcionPropuesta>0){
                     cont ++;
                     costo = propuestas[i].costoVoto;
                }
            }
        }
        if (cont == 0){
            return "Error, su voto no fue expedido";
        }
        if (totalvotos[msg.sender][_codigoPropuesta]>4){
            return "No puedes votar mas de 5 veces";
        }
        precio = (2**totalvotos[msg.sender][_codigoPropuesta])*costo;
        dineroopcion[_codigoPropuesta][_opcionPropuesta] += precio;
        totalvotos[msg.sender][_codigoPropuesta] ++;
        votantes.push(votante(payable(msg.sender)));
        if (aucEnd(_codigoPropuesta)){
            return "No puedes votar el tiempo ha acabado";
        }
        return "Voto realizado";
    }

    function NombrarBeneficiario(address _beneficiario, uint _codigoPropuesta) public esPresidente returns(string memory){
        if (aucEnd(_codigoPropuesta)){
            return "No puedes agregar beneficiarios el tiempo ha acabado";
        }
        uint cont = 0;
        uint contvot = 0;
        for (uint i=0; i<propuestas.length;i++){
            if(propuestas[i].codigoPropuesta == _codigoPropuesta){
                cont ++;
            }
        }
        if (cont == 0){
            return "Error, la propuesta no existe";
        }
        for (uint i=0; i<votantes.length;i++){
            if(votantes[i].codigoVotante == _beneficiario){
                contvot ++;
            }
        }
        if (contvot == 0){
            return "Error, el votante no existe";
        }
        if (beneficiarios[_codigoPropuesta].length>4){
            return "Ya se alcanzo el maximo de beneficiarios";
        }
        for (uint i=0; i<beneficiarios[_codigoPropuesta].length;i++){
            if (beneficiarios[_codigoPropuesta][i] == _beneficiario){
                return "Ya es beneficiario";
            }
        }
        beneficiarios[_codigoPropuesta].push(payable (_beneficiario));
        return "Beneficiario agregado";
    }

    function EntregaResultados(uint _codigoPropuesta) public esPresidente returns(string memory){
        if (!aucEnd(_codigoPropuesta)){
            return "No se ha terminado el tiempo";
        }
        uint cont = 0;
        uint a;
        uint longitud;
        string memory aux = "";
        for (uint i=0; i<propuestas.length;i++){
            if(propuestas[i].codigoPropuesta == _codigoPropuesta){
                cont ++;
                longitud = propuestas[i].cantidadOpciones;
            }
        }
        if (cont == 0){
            return "Error, la propuesta no existe";
        }
        for (uint i=1;i<longitud+1;i++){
            a = dineroopcion[_codigoPropuesta][i];
            //Strings.toString(a);
            aux = string(abi.encodePacked(aux,Strings.toString(i), ": ", Strings.toString(a), " "));
        }
        aux = string(abi.encodePacked(aux, " Dinero cambios: ", Strings.toString(dineroCambio[_codigoPropuesta])));
        return aux;
    }

    function TransferirDinero(uint _codigoPropuesta) public esPresidente returns(string memory){
        if (!aucEnd(_codigoPropuesta)){
            return "No se ha terminado el tiempo";
        }
        uint cont = 0;
        uint longitud;
        uint dinero;
        for (uint i=0; i<propuestas.length;i++){
            if(propuestas[i].codigoPropuesta == _codigoPropuesta){
                cont ++;
                longitud = propuestas[i].cantidadOpciones;
            }
        }
        if (cont == 0){
            return "Error, la propuesta no existe";
        }
        for (uint i=1;i<longitud+1;i++){
            dinero += dineroopcion[_codigoPropuesta][i];
        }
        if (beneficiarios[_codigoPropuesta].length == 0){
            presidente.transfer(dinero);
            return "Todo el dinero lo recibe el presidente";
        }
        presidente.transfer(dinero/2);
        presidente.transfer(dineroCambio[_codigoPropuesta]);
        for (uint i=0;i<beneficiarios[_codigoPropuesta].length;i++){
            beneficiarios[_codigoPropuesta][i].transfer(dinero/(2*beneficiarios[_codigoPropuesta].length));
        }
        return "Se ha pagado al presidente y a los beneficiarios";
    }

    function ConsultarDineroPropuesta(uint _codigoPropuesta) public esAdmin(_codigoPropuesta) returns(string memory){
        if (!aucEnd(_codigoPropuesta)){
            return "No se ha terminado el tiempo";
        }
        uint cont = 0;
        uint longitud;
        uint dinero;
        uint a;
        uint b;
        for (uint i=0; i<propuestas.length;i++){
            if(propuestas[i].codigoPropuesta == _codigoPropuesta){
                cont ++;
                longitud = propuestas[i].cantidadOpciones;
            }
        }
        if (cont == 0){
            return "Error, la propuesta no existe";
        }
        for (uint i=1;i<longitud+1;i++){
            dinero += dineroopcion[_codigoPropuesta][i];
        }
        if (beneficiarios[_codigoPropuesta].length == 0){
            return string(abi.encodePacked("Todo el dinero lo recibe el presidente: ", Strings.toString(dinero)));
        }
        a = dinero/2 + dineroCambio[_codigoPropuesta];
        b = dinero/(2*beneficiarios[_codigoPropuesta].length);
        return string(abi.encodePacked("El presidente recibe: ", Strings.toString(a), " Cada uno de los beneficiarios recibe: ", Strings.toString(b)));
    }

    function ConsultarDineroTodas(uint _codigoPropuesta) public esPresidente returns(string memory){
        uint contador = 0;
        for (uint a=0; a<propuestas.length;a++){
                if (aucEnd(propuestas[a].codigoPropuesta)){
                    contador ++;
            }
        }
        if (contador != propuestas.length){
            return "No se han terminado todas las propuestas";
        }
        uint dinero;
        string memory aux;
        for (uint i=0; i<propuestas.length;i++){
            for (uint j=0;i<propuestas[i].cantidadOpciones;j++){
                aux = string(abi.encodePacked(aux, Strings.toString(propuestas[i].codigoPropuesta), ": ",Strings.toString(dineroopcion[propuestas[i].codigoPropuesta][j]),"  "));
            }
            aux = string(abi.encodePacked(aux, "Dinero cambio", dineroCambio[propuestas[i].codigoPropuesta]));
        }
        return aux;
    }

    function AumentaTiempo(uint _codigoPropuesta, uint aumento) public esAdmin(_codigoPropuesta) returns(string memory){
        if (aucEnd(_codigoPropuesta)){
            return "El tiempo ha acabado";
        }
        if (aumento>300){
            return "Error mucho tiempo";
        }
        uint precio;
        if (aumento%60 == 0){
            if (aumentoTiempo[_codigoPropuesta]>4){
                aumentoTiempo[_codigoPropuesta] += 1;
                tiempoRestante[_codigoPropuesta] += aumento;
                precio = aumento%60;
                dineroCambio[_codigoPropuesta] += precio;
                return "tiempo agregado";
            }
        }
    }

    function DecrementaTiempo(uint _codigoPropuesta, uint aumento) public esAdmin(_codigoPropuesta) returns(string memory){
        if (aucEnd(_codigoPropuesta)){
            return "El tiempo ha acabado";
        }
        if (aumento>180){
            return "Error mucho tiempo";
        }
        uint precio;
        if (aumento%60 == 0){
            if (reduccionTiempo[_codigoPropuesta]>2){
                if (block.timestamp - tiempoRestante[_codigoPropuesta] > 120){
                    reduccionTiempo[_codigoPropuesta] += 1;
                    tiempoRestante[_codigoPropuesta] += aumento;
                    precio = aumento%60*2;
                    dineroCambio[_codigoPropuesta] += precio;
                    return "tiempo reducido";
                }
            }
        }
    }
}