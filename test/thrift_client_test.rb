require File.dirname(__FILE__) + '/test_helper'

class ThriftClientTest < Test::Unit::TestCase
  context "scanner methods" do
    setup do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('drop table if exists thrift_test')
        client.hql_query('create table thrift_test ( col1, col2 )')
        client.hql_query("insert into thrift_test values \
          ('2008-11-11 11:11:11', 'k1', 'col1', 'v1c1'), \
          ('2008-11-11 11:11:11', 'k1', 'col2', 'v1c2'), \
          ('2008-11-11 11:11:11', 'k2', 'col1', 'v2c1'), \
          ('2008-11-11 11:11:11', 'k2', 'col2', 'v2c2'), \
          ('2008-11-11 11:11:11', 'k3', 'col1', 'v3c1'), \
          ('2008-11-11 11:11:11', 'k3', 'col2', 'v3c2')");
      end
    end

    context "each cell" do
      should "return cells individually" do
        Hypertable.with_thrift_client("localhost", 38080) do |client|
          scan_spec = Hypertable::ThriftGen::ScanSpec.new
          client.with_scanner("thrift_test", scan_spec) do |scanner|
            cell_count = 0
            client.each_cell(scanner) do |cell|
              assert_equal Hypertable::ThriftGen::Cell, cell.class
              cell_count += 1
            end
            assert_equal 6, cell_count
          end
        end
      end
    end

    context "each cell as arrays" do
      should "return cells individually in native array format" do
        Hypertable.with_thrift_client("localhost", 38080) do |client|
          scan_spec = Hypertable::ThriftGen::ScanSpec.new
          client.with_scanner("thrift_test", scan_spec) do |scanner|
            cell_count = 0
            client.each_cell_as_arrays(scanner) do |cell|
              assert_equal Array, cell.class
              cell_count += 1
            end
            assert_equal 6, cell_count
          end
        end
      end
    end

    context "each row" do
      should "return rows individually" do
        Hypertable.with_thrift_client("localhost", 38080) do |client|
          scan_spec = Hypertable::ThriftGen::ScanSpec.new
          client.with_scanner("thrift_test", scan_spec) do |scanner|
            cell_count = 0
            row_count = 0
            client.each_row(scanner) do |row|
              assert_equal Array, row.class
              assert_equal 2, row.length
              row.each do |cell| 
                assert_equal Hypertable::ThriftGen::Cell, cell.class
                cell_count +=1
              end
              row_count += 1
            end
            assert_equal 6, cell_count
            assert_equal 3, row_count
          end
        end
      end
    end

    context "each row as arrays" do
      should "return rows individually in native array format" do
        Hypertable.with_thrift_client("localhost", 38080) do |client|
          scan_spec = Hypertable::ThriftGen::ScanSpec.new
          client.with_scanner("thrift_test", scan_spec) do |scanner|
            cell_count = 0
            row_count = 0
            client.each_row_as_arrays(scanner) do |row|
              assert_equal Array, row.class
              assert_equal 2, row.length
              row.each do |cell| 
                assert_equal Array, cell.class
                cell_count +=1
              end
              row_count += 1
            end
            assert_equal 6, cell_count
            assert_equal 3, row_count
          end
        end
      end
    end

    context "scan spec" do
      should "return all rows on empty scan spec" do
        Hypertable.with_thrift_client("localhost", 38080) do |client|
          scan_spec = Hypertable::ThriftGen::ScanSpec.new
          cells = client.get_cells("thrift_test", scan_spec)
          assert_equal 6, cells.length
        end
      end

      context "limit" do
        should "return just the first rows on empty scan spec with limit of 1" do
          Hypertable.with_thrift_client("localhost", 38080) do |client|
            scan_spec = Hypertable::ThriftGen::ScanSpec.new
            scan_spec.row_limit = 1
            cells = client.get_cells("thrift_test", scan_spec)
            assert_equal 2, cells.length
          end
        end
      end

      context "cell interval" do
        should "return matching cells on cell interval" do
          Hypertable.with_thrift_client("localhost", 38080) do |client|
            cell_interval = Hypertable::ThriftGen::CellInterval.new
            cell_interval.start_row = 'k1'
            cell_interval.start_column = 'col2'
            cell_interval.start_inclusive = true
            cell_interval.end_row = 'k3'
            cell_interval.end_column = 'col1'
            cell_interval.end_inclusive = true

            scan_spec = Hypertable::ThriftGen::ScanSpec.new
            scan_spec.cell_intervals = [cell_interval]
            cells = client.get_cells("thrift_test", scan_spec)
            assert_equal 4, cells.length
          end
        end
      end

      context "row interval" do
        should "return matching rows on row interval with start row and start inclusive" do
          Hypertable.with_thrift_client("localhost", 38080) do |client|
            row_interval = Hypertable::ThriftGen::RowInterval.new
            row_interval.start_row = 'k2'
            row_interval.start_inclusive = true
            row_interval.end_row = 'k3'
            row_interval.end_inclusive = true

            scan_spec = Hypertable::ThriftGen::ScanSpec.new
            scan_spec.row_intervals = [row_interval]
            cells = client.get_cells("thrift_test", scan_spec)
            assert_equal 4, cells.length
          end
        end

        should "return matching rows on row interval with start row and start exclusive" do
          Hypertable.with_thrift_client("localhost", 38080) do |client|
            row_interval = Hypertable::ThriftGen::RowInterval.new
            row_interval.start_row = 'k2'
            row_interval.start_inclusive = false
            row_interval.end_row = 'k3'
            row_interval.end_inclusive = true

            scan_spec = Hypertable::ThriftGen::ScanSpec.new
            scan_spec.row_intervals = [row_interval]
            cells = client.get_cells("thrift_test", scan_spec)
            assert_equal 2, cells.length
          end
        end

        should "return matching rows on row interval with end row and end inclusive" do
          Hypertable.with_thrift_client("localhost", 38080) do |client|
            row_interval = Hypertable::ThriftGen::RowInterval.new
            row_interval.start_row = 'k1'
            row_interval.start_inclusive = true
            row_interval.end_row = 'k2'
            row_interval.end_inclusive = true

            scan_spec = Hypertable::ThriftGen::ScanSpec.new
            scan_spec.row_intervals = [row_interval]
            cells = client.get_cells("thrift_test", scan_spec)
            assert_equal 4, cells.length
          end
        end

        should "return matching rows on row interval with end row and end exclusive" do
          Hypertable.with_thrift_client("localhost", 38080) do |client|
            row_interval = Hypertable::ThriftGen::RowInterval.new
            row_interval.start_row = 'k1'
            row_interval.start_inclusive = true
            row_interval.end_row = 'k2'
            row_interval.end_inclusive = false

            scan_spec = Hypertable::ThriftGen::ScanSpec.new
            scan_spec.row_intervals = [row_interval]
            cells = client.get_cells("thrift_test", scan_spec)
            assert_equal 2, cells.length
          end
        end
      end
    end
  end

  context "set cell" do
    setup do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('drop table if exists thrift_test')
        client.hql_query('create table thrift_test ( col )')
      end
    end

    should "insert a cell using hql_query" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query("insert into thrift_test values \
          ('2008-11-11 11:11:11', 'k1', 'col', 'v1')");

        query = client.hql_query("SELECT * FROM thrift_test")
        assert_equal 1, query.cells.length
        assert_equal 'k1', query.cells[0].key.row
        assert_equal 'col', query.cells[0].key.column_family
        assert_equal 'v1', query.cells[0].value
      end
    end

    should "insert a cell using set_cell" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        mutator = client.open_mutator('thrift_test', 0, 0)
        cell1 = Hypertable::ThriftGen::Cell.new
        cell1.key = Hypertable::ThriftGen::Key.new
        cell1.key.row = 'k1'
        cell1.key.column_family = 'col'
        cell1.value = 'v1'
        client.set_cell(mutator, cell1)
        client.close_mutator(mutator, true)

        query = client.hql_query("SELECT * FROM thrift_test")
        assert_equal 1, query.cells.length
        assert_equal 'k1', query.cells[0].key.row
        assert_equal 'col', query.cells[0].key.column_family
        assert_equal 'v1', query.cells[0].value
      end
    end

    should "work with mutator flush_interval" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        mutator = client.open_mutator('thrift_test', 0, 500)
        cell1 = Hypertable::ThriftGen::Cell.new
        cell1.key = Hypertable::ThriftGen::Key.new
        cell1.key.row = 'k1'
        cell1.key.column_family = 'col'
        cell1.value = 'v1'
        client.set_cell(mutator, cell1)

        query = client.hql_query("SELECT * FROM thrift_test")
        assert_equal 0, query.cells.length

        sleep 1

        query = client.hql_query("SELECT * FROM thrift_test")
        assert_equal 1, query.cells.length
        assert_equal 'k1', query.cells[0].key.row
        assert_equal 'col', query.cells[0].key.column_family
        assert_equal 'v1', query.cells[0].value
      end
    end
  end

  context "set cells" do
    setup do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('drop table if exists thrift_test')
        client.hql_query('create table thrift_test ( col )')
      end
    end

    should "insert cells using hql_query" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query("insert into thrift_test values \
          ('2008-11-11 11:11:11', 'k1', 'col', 'v1'), \
          ('2008-11-11 11:11:11', 'k2', 'col', 'v2'), \
          ('2008-11-11 11:11:11', 'k3', 'col', 'v3')");

        query = client.hql_query("SELECT * FROM thrift_test")
        assert_equal 3, query.cells.length
        assert_equal 'k1', query.cells[0].key.row
        assert_equal 'col', query.cells[0].key.column_family
        assert_equal 'v1', query.cells[0].value

        assert_equal 'k2', query.cells[1].key.row
        assert_equal 'col', query.cells[1].key.column_family
        assert_equal 'v2', query.cells[1].value

        assert_equal 'k3', query.cells[2].key.row
        assert_equal 'col', query.cells[2].key.column_family
        assert_equal 'v3', query.cells[2].value
      end
    end

    should "insert cells using set_cells" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        mutator = client.open_mutator('thrift_test', 0, 0)
        cell1 = Hypertable::ThriftGen::Cell.new
        cell1.key = Hypertable::ThriftGen::Key.new
        cell1.key.row = 'k1'
        cell1.key.column_family = 'col'
        cell1.value = 'v1'

        cell2 = Hypertable::ThriftGen::Cell.new
        cell2.key = Hypertable::ThriftGen::Key.new
        cell2.key.row = 'k2'
        cell2.key.column_family = 'col'
        cell2.value = 'v2'

        cell3 = Hypertable::ThriftGen::Cell.new
        cell3.key = Hypertable::ThriftGen::Key.new
        cell3.key.row = 'k3'
        cell3.key.column_family = 'col'
        cell3.value = 'v3'

        client.set_cells(mutator, [cell1, cell2, cell3])
        client.close_mutator(mutator, true)

        query = client.hql_query("SELECT * FROM thrift_test")
        assert_equal 3, query.cells.length
        assert_equal 'k1', query.cells[0].key.row
        assert_equal 'col', query.cells[0].key.column_family
        assert_equal 'v1', query.cells[0].value

        assert_equal 'k2', query.cells[1].key.row
        assert_equal 'col', query.cells[1].key.column_family
        assert_equal 'v2', query.cells[1].value

        assert_equal 'k3', query.cells[2].key.row
        assert_equal 'col', query.cells[2].key.column_family
        assert_equal 'v3', query.cells[2].value
      end
    end
  end

  context "with mutator" do
    setup do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('drop table if exists thrift_test')
        client.hql_query('create table thrift_test ( col )')
      end
    end

    should "yield a mutator object and close after block" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        query = client.hql_query("SELECT * FROM thrift_test")
        assert_equal 0, query.cells.length

        client.with_mutator('thrift_test') do |mutator|
          cell1 = Hypertable::ThriftGen::Cell.new
          cell1.key = Hypertable::ThriftGen::Key.new
          cell1.key.row = 'k1'
          cell1.key.column_family = 'col'
          cell1.value = 'v1'
          client.set_cells(mutator, [cell1])
        end

        query = client.hql_query("SELECT * FROM thrift_test")
        assert_equal 1, query.cells.length
        assert_equal 'k1', query.cells[0].key.row
        assert_equal 'col', query.cells[0].key.column_family
        assert_equal 'v1', query.cells[0].value
      end
    end
  end

  context "get cell" do
    setup do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('drop table if exists thrift_test')
        client.hql_query('create table thrift_test ( col )')
        client.hql_query("insert into thrift_test values \
          ('2008-11-11 11:11:11', 'k1', 'col', 'v1'), \
          ('2008-11-11 11:11:11', 'k2', 'col', 'v2'), \
          ('2008-11-11 11:11:11', 'k3', 'col', 'v3')");
      end
    end

    should "return a single cell using hql_query" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        query = client.hql_query("SELECT * FROM thrift_test WHERE CELL = 'k1','col'")
        assert_equal 1, query.cells.length
        assert_equal 'k1', query.cells[0].key.row
        assert_equal 'col', query.cells[0].key.column_family
        assert_equal 'v1', query.cells[0].value
      end
    end

    should "return a single cell using get_cell" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        value = client.get_cell("thrift_test", 'k1', 'col')
        assert_equal 'v1', value
      end
    end
  end

  context "get row" do
    setup do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('drop table if exists thrift_test')
        client.hql_query('create table thrift_test ( col )')
        client.hql_query("insert into thrift_test values \
          ('2008-11-11 11:11:11', 'k1', 'col', 'v1'), \
          ('2008-11-11 11:11:11', 'k2', 'col', 'v2'), \
          ('2008-11-11 11:11:11', 'k3', 'col', 'v3')");
      end
    end

    should "return a single row using hql_query" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        query = client.hql_query("SELECT * FROM thrift_test WHERE ROW = 'k1'")
        assert_equal 1, query.cells.length
        assert_equal 'k1', query.cells[0].key.row
        assert_equal 'col', query.cells[0].key.column_family
        assert_equal 'v1', query.cells[0].value
      end
    end

    should "return a single row using get_row" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        cells = client.get_row("thrift_test", 'k1')
        assert_equal 1, cells.length
        assert_equal 'k1', cells[0].key.row
        assert_equal 'col', cells[0].key.column_family
        assert_equal 'v1', cells[0].value
      end
    end
  end

  context "get cells" do
    setup do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('drop table if exists thrift_test')
        client.hql_query('create table thrift_test ( col )')
        client.hql_query("insert into thrift_test values \
          ('2008-11-11 11:11:11', 'k1', 'col', 'v1'), \
          ('2008-11-11 11:11:11', 'k2', 'col', 'v2'), \
          ('2008-11-11 11:11:11', 'k3', 'col', 'v3')");
      end
    end

    should "return a list of cells using hql_query" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        query = client.hql_query("SELECT * FROM thrift_test")
        assert_equal 3, query.cells.length
        assert_equal 'k1', query.cells[0].key.row
        assert_equal 'col', query.cells[0].key.column_family
        assert_equal 'v1', query.cells[0].value

        assert_equal 'k2', query.cells[1].key.row
        assert_equal 'col', query.cells[1].key.column_family
        assert_equal 'v2', query.cells[1].value

        assert_equal 'k3', query.cells[2].key.row
        assert_equal 'col', query.cells[2].key.column_family
        assert_equal 'v3', query.cells[2].value
      end
    end

    should "return a list of cells using get_cells" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        scan_spec = Hypertable::ThriftGen::ScanSpec.new
        cells = client.get_cells("thrift_test", scan_spec)

        assert_equal 3, cells.length
        assert_equal 'k1', cells[0].key.row
        assert_equal 'col', cells[0].key.column_family
        assert_equal 'v1', cells[0].value

        assert_equal 'k2', cells[1].key.row
        assert_equal 'col', cells[1].key.column_family
        assert_equal 'v2', cells[1].value

        assert_equal 'k3', cells[2].key.row
        assert_equal 'col', cells[2].key.column_family
        assert_equal 'v3', cells[2].value
      end
    end
  end

  context "get schema" do
    setup do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('drop table if exists thrift_test')
        query = client.hql_query('show tables')
        assert !query.results.include?('thrift_test'), "table exists after drop"
        client.hql_query('create table thrift_test ( col )')
      end
    end

    should "return the table definition using hql_query" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        query = client.hql_query('show create table thrift_test')
        assert query.results.first.include?('CREATE TABLE thrift_test')
        assert query.results.first.include?('col')
      end
    end

    should "return the table definition using get_schema_str" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        results = client.get_schema_str('thrift_test')
        assert results.include?('<Name>col</Name>')
      end
    end
  end

  context "get tables" do
    setup do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('drop table if exists thrift_test')
        query = client.hql_query('show tables')
        assert !query.results.include?('thrift_test'), "table exists after drop"
        client.hql_query('create table thrift_test ( col )')
      end
    end

    should "return a list of table using hql_query" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        query = client.hql_query('show tables')
        assert query.results.include?('thrift_test'), "table does not exist after create"
      end
    end

    should "return a list of table using get_tables" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        results = client.get_tables
        assert results.include?('thrift_test'), "table does not exist after create"
      end
    end
  end

  context "drop table" do
    setup do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('drop table if exists thrift_test')
        query = client.hql_query('show tables')
        assert !query.results.include?('thrift_test'), "table exists after drop"

        client.hql_query('create table thrift_test ( col )')
        query = client.hql_query('show tables')
        assert query.results.include?('thrift_test'), "table does not exist after create"
      end
    end

    should "drop a table if one exists using hql_query" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('drop table if exists thrift_test')
        query = client.hql_query('show tables')
        assert !query.results.include?('thrift_test'), "table exists after drop"
      end
    end

    should "drop a table if one exists using drop_table" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.drop_table('thrift_test', true)
        query = client.hql_query('show tables')
        assert !query.results.include?('thrift_test'), "table exists after drop"
      end
    end
  end

  context "create table" do
    setup do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('drop table if exists thrift_test')
        query = client.hql_query('show tables')
        assert !query.results.include?('thrift_test'), "table exists after drop"
      end
    end

    should "create a table that matches the supplied schema with hql_query" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        client.hql_query('create table thrift_test ( col )')
        query = client.hql_query('show tables')
        assert query.results.include?('thrift_test'), "table does not exist after create"
      end
    end

    should "create a table that matches the supplied schema with create_table" do
      Hypertable.with_thrift_client("localhost", 38080) do |client|
        table_schema =<<EOF
<Schema>
<AccessGroup name="default">
  <ColumnFamily>
    <Name>col</Name>
  </ColumnFamily>
</AccessGroup>
</Schema>
EOF
        client.create_table('thrift_test', table_schema)
        query = client.hql_query('show tables')
        assert query.results.include?('thrift_test'), "table does not exist after create"
      end
    end
  end
end
