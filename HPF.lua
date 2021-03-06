Class            = require "lib.Class"
local Procesador = Class:derive("SRT")
local tiempo = 0
tiempo_real = 0

function Procesador:new()
    self.procesos = {}
    self.procesos_graf = {}
end

function Procesador:agregar_proceso(nuevo_proceso)
    table.insert( self.procesos,nuevo_proceso)
end

local primero = true

function Procesador:update(dt)
    if pausa == false then
        if tiempo > 1 then
            if ( #self.procesos >= 2 ) then
                for i = 2 , #self.procesos , 1 do
                    for j = 1 , #self.procesos -1 , 1 do
                        if(self.procesos[j].prioridad == self.procesos[j+1].prioridad) then
                            if ( self.procesos[j].t_proceso - self.procesos[j].var > self.procesos[j+1].t_proceso - self.procesos[j+1].var ) then
                                temp = self.procesos[j]
                                self.procesos[j] = self.procesos[j+1]
                                self.procesos[j+1] = temp
                            end
                        end

                        if ( self.procesos[j].prioridad > self.procesos[j+1].prioridad ) then
                            temp = self.procesos[j]
                            self.procesos[j] = self.procesos[j+1]
                            self.procesos[j+1] = temp
                        end 
                    end
                end
            end

            if ( #self.procesos ~= 0 ) then

                if primero == true or primero == false then
                    if(self.procesos[1].espera == false) then
                        (self.procesos[1]).t_inicio = (self.procesos[1]).t_llegada
                        self.procesos[1].espera = true
                        primero = false
                    end
                end

                if ( (self.procesos[1]).t_proceso-1 == (self.procesos[1]).var ) then
                        self.procesos[1].t_fin = tiempo_real + 1
                        table.insert( self.procesos_graf,self.procesos[1])
                        table.remove(self.procesos,1)
                        print("Proceso Terminado")
                else
                    self.procesos[1].var = self.procesos[1].var + 1 
                end

            else
                primero = true     
            end
            tiempo = 0
            tiempo_real = tiempo_real + 1;
        end
        tiempo = tiempo + dt
    end
end 

function Procesador:draw()
    cont_y2 = 580
    cont_x  = 10
    cont_y  = 60
    cont_x2 = 50
    cont_y3 = 570
    cont_x3 = 0

    if #self.procesos == 0 then
        love.graphics.print("NO HAY PROCESOS",love.graphics.getWidth()/2-60,cont_y)
    end
    
    if #self.procesos ~= 0 then
        love.graphics.print("NOMBRE        DURACION        T.LLEGADA        PRIORIDAD        EJECUTANDO",10,40)
        for k,v in pairs(self.procesos) do
            love.graphics.print(v.nombre,cont_x,cont_y)
            love.graphics.print(v.t_proceso - v.var,cont_x+100,cont_y)
            love.graphics.print(v.t_llegada,cont_x+200,cont_y)
            love.graphics.print(v.prioridad,cont_x+300,cont_y)
            cont_y = cont_y + 15
            --love.graphics.setColor(1,0.38,0.27)
            love.graphics.rectangle("line",cont_x+400,cont_y-15,v.t_proceso*5,5)
            love.graphics.rectangle("fill",cont_x+400,cont_y-15,v.var*5,5)
            --love.graphics.setColor(1, 1, 1)
        end
    end

    if #self.procesos_graf ~= 0 then
        for k,v in pairs(self.procesos_graf) do
            love.graphics.print(v.nombre,5,cont_y3-10)
            love.graphics.setColor(0.45, 1, 0.2)
            love.graphics.rectangle("fill",v.t_inicio*10+20,cont_y3,(v.t_fin-v.t_inicio)*10,5)
            love.graphics.setColor(255, 255, 255)
            if (#self.procesos_graf >= 2 and k > 1 ) then
                love.graphics.setColor(0,0,0)
                i = k - 1
                while(i>0) do
                    love.graphics.rectangle("fill",self.procesos_graf[i].t_inicio*10+20,cont_y3,( self.procesos_graf[i].t_fin-self.procesos_graf[i].t_inicio)*10,5)
                    i = i - 1 
                end
                love.graphics.setColor(255, 255, 255)
            end

            love.graphics.print("|"..v.t_inicio,v.t_inicio*10+20,cont_y2)
            love.graphics.print("|"..v.t_fin,v.t_fin*10+20,cont_y2)
            cont_y3 = cont_y3 - 20
        end
        love.graphics.print("|0",20,cont_y2)
    end
    love.graphics.setColor(0.97,0.95,0.2)
    love.graphics.print("Segundo actual: "..tiempo_real,10,10)

end

return Procesador
