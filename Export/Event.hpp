/// @file Event.hpp
///
/// Declaración de la base para los eventos de la SM
///
/// @author   Diego Viqueira
/// @version  1.0
/// @date     27/08/2015
///
/// @bug 
/// @warning 

#ifndef __CONSUMED_EVENT_HPP__
#define __CONSUMED_EVENT_HPP__

#include <ats/base/alloc/shared_ptr.hpp>
#include <ats/base/alloc/enable_shared_from_this.hpp>

using namespace ats;

namespace example 
{
	namespace events
	{
		
		/*
		
		    La idea de esta interfaz es permitir generar toda una familia de eventos utilizando herencia. 
		    La el parámetro template Processor es la clase encargada de resolver el polimorfismo implementando un método Process
		    por cada Evento derivado de AEvent<Processor>.
		    
		    Ej:
		    
		    //forward declaration
		    class CEvent1;
		    class CEvent2;
		    
		    class CProcessor
		    {
		    	public:
		    	bool Process( CEvent1& oEvent)
		      {
		         ///Procesamiento del evento1
		      }
		    	bool Process( CEvent2& oEvent);
		      {
		         ///Procesamiento del evento2
		      }
		    };
		    
		    class CEvent1: public AEvent< CProcessor >
		    {
		    		bool Process( CProcessor& oEventProcessor )
		    		{
		    				oEventProcessor.Process(*this);
		    		}
		    		....
		    };
		    class CEvent2: public AEvent< CProcessor >
		    {
		    		bool Process( CProcessor& oEventProcessor )
		    		{
		    				oEventProcessor.Process(*this);
		    		}
		    		....
		    };
		    
		    
		    De esta manera se puede tener una cola de punteros a eventos del tipo AEvent< CProcessor > y utilzar el processor
		    para evitar tener que hacer dynamic casts para determinar de que evento se trata:
		    
		    CProcessor oProcessor;
		    while()
		    {
		        base::alloc::shared_ptr< AEvent< CProcessor> > pEvent= evt_queue.Get();
		        pEvent.Process(oProcessor);
		    }
		*/
	
		template< class Processor >
		class AEvent: public base::alloc::enable_shared_from_this< AEvent< Processor > >
		{
		public:
			/*
					Consumidor del evento. Los autmómatas suelen derivar de esta interfaz para poder de esta meanera asociar
					a los eventos de una misma sesión al mismo autómata, que es consumidor de los mismos.
			*/
			class IEventConsumer
			{
			  public:
                virtual ~IEventConsumer(){};
				virtual base::int_types::UInt64 GetSessionId() =0;
				virtual bool Run(AEvent& oEvent) =0;
			};//IEventConsumer
			/*
					El objeto que implemente la cola de eventos debe derivar de esta interfaz para poder recibir los mismos.
			*/
			class IEventReceiver
			{
			public:
                virtual ~IEventReceiver(){};
				virtual bool SendEvent(base::alloc::shared_ptr< AEvent > spEvent) =0;
			};	//IEventReceiver
			
            AEvent(){}
			
            AEvent(base::alloc::shared_ptr< IEventConsumer> spConsumer):m_spConsumer(spConsumer){}
			
            virtual ~AEvent(){}
			
            base::alloc::shared_ptr< IEventConsumer> Consumer() const{ return  m_spConsumer;}
			void Consumer( base::alloc::shared_ptr< IEventConsumer> spConsumer )
			{
				 m_spConsumer = spConsumer;
			}

			virtual const char* GetName() =0;
			virtual bool Process(Processor& oEventProcessor)=0;
		
            protected:
    			base::alloc::shared_ptr< IEventConsumer> m_spConsumer;
		};
	}
}

#endif
